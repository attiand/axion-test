package se.uhr.nya.db

import org.eclipse.jgit.api.Git
import org.eclipse.jgit.treewalk.CanonicalTreeParser
import org.eclipse.jgit.lib.*

class DatabaseVersion {

    private final Git git

    public DatabaseVersion(File gitRepoRoot) {
        git = Git.open(gitRepoRoot)
    }

    public List<String> newPaths(def previousVersion, def releaseVersion) {
        def repository = git.getRepository()

        ObjectId p = repository.resolve(previousVersion + '^{tree}')
        ObjectId c = repository.resolve(releaseVersion + '^{tree}')

        ObjectReader reader = repository.newObjectReader()
        CanonicalTreeParser pTreeIter = new CanonicalTreeParser()
        pTreeIter.reset(reader, p);
        CanonicalTreeParser cTreeIter = new CanonicalTreeParser()
        cTreeIter.reset(reader, c)

        def diffs = git.diff()
                .setNewTree(cTreeIter)
                .setOldTree(pTreeIter)
                .call()

        return diffs.collect { d ->
            d.getNewPath()
        }
    }

    public List<String> versions(def previousVersion, def releaseVersion) {
        def upgrades = newPaths(previousVersion, releaseVersion).findResults { p ->
            p.getNewPath().find(~/\/migration\/(V[^\/]+)/) { _, v ->
                v
            }
        }
    }
}