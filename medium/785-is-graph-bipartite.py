class Solution(object):
    def isBipartite(self, graph):
        """
        :type graph: List[List[int]]
        :rtype: bool
        """
        partition1, partition2, checked, unchecked = set(), set(), set(), {0}

        while unchecked or len(unchecked) != len(graph):
            if not unchecked:
                available_ = (set(range(len(graph))) - checked)
                if available_:
                    unchecked.add(available_.pop())
                else:
                    break
            index = unchecked.pop()
            node = graph[index]
            if not node:

                available_ = (set(range(len(graph))) - checked - {index})
                if available_:
                    index = available_.pop()
                    node = graph[index]
                else:
                    break

            if partition1 & set(node):
                partition1.update(node)
                partition2.add(index)
            else:
                partition1.add(index)
                partition2.update(node)

            checked.add(index)
            unchecked.update(set(node) - checked)

            if partition1 & partition2 != set():
                return False

        return True

# For the record, this solution is on average O(V^2) with worst case O(V^3). BFS is O(V + E) as long as you're smart