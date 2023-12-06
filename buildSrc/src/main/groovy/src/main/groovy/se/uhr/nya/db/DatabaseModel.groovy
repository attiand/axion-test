package se.uhr.nya.db

import java.util.regex.Pattern
import org.eclipse.jgit.api.Git
import org.eclipse.jgit.treewalk.CanonicalTreeParser
import org.eclipse.jgit.treewalk.AbstractTreeIterator
import org.eclipse.jgit.treewalk.FileTreeIterator
import org.eclipse.jgit.lib.*

class DatabaseModel {

    private static Pattern VERSION_PATTERN = ~/\/migration\/(V[^\/]+)/

    private final Git git

    DatabaseModel(File gitRepoRoot) {
        git = Git.open(gitRepoRoot)
    }

    /**
     * List migrations from previousVersion and workspace.
     *
     * @param previousVersion Version to list from.
     * @return List of migrations
     */

    List<String> migrations(String previousVersion) {
        newPaths(createTreeIterator(previousVersion), new FileTreeIterator(git.getRepository())).findResults { p ->
            p.find(VERSION_PATTERN) { _, v ->
                v
            }
        }
    }

    /**
     * List migrations from previousVersion and specified version.
     *
     * @param previousVersion Version to list from.
     * @param newVersion Version to list to.
     * @return List of migrations
     */

    List<String> migrations(String previousVersion, String newVersion) {
        newPaths(createTreeIterator(previousVersion), createTreeIterator(newVersion)).findResults { p ->
            p.find(VERSION_PATTERN) { _, v ->
                v
            }
        }
    }

    private List<String> newPaths(AbstractTreeIterator previous, AbstractTreeIterator current) {
        def diffs = git.diff()
                .setOldTree(previous)
                .setNewTree(current)
                .call()

        return diffs.collect { d ->
            d.getNewPath()
        }
    }

    private AbstractTreeIterator createTreeIterator(def version) {
        def repository = git.getRepository()
        ObjectId id = repository.resolve(version + '^{tree}')
        ObjectReader reader = repository.newObjectReader()
        CanonicalTreeParser tree = new CanonicalTreeParser()
        tree.reset(reader, id)
        return tree
    }
}
