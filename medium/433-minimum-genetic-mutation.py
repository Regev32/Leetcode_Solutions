def mut_dist(gene1, gene2):
    return sum([gene1[i] != gene2[i] for i in range(len(gene1))]) == 1

class Solution:
    def minMutation(self, startGene: str, endGene: str, bank: List[str]) -> int:
        graph = [[] for _ in range(len(bank) + 2)]
        if not endGene in bank:
            return -1
        if mut_dist(startGene, endGene):
            graph[0].append(len(bank) + 1)
            graph[len(bank) + 1].append(0)
        for i, gene in enumerate(bank):
            if mut_dist(startGene, gene):
                graph[0].append(i + 1)
                graph[i + 1].append(0)
            if mut_dist(endGene, gene):
                graph[len(bank) + 1].append(i + 1)
                graph[i + 1].append(len(bank) + 1)
            for j, gene1 in enumerate(bank):
                if mut_dist(gene, gene1):
                    graph[i + 1].append(j + 1)

        queue = [(0, 0)]
        visited = {0}
        while queue:
            node, dist = queue.pop(0)
            if node == len(bank) + 1:
                return dist

            for neighbor in graph[node]:
                if neighbor not in visited:
                    queue.append((neighbor, dist + 1))
                    visited.add(neighbor)
        return -1

# For faster time, do an "on-the-go" BFS:
# Take startGene, generate all one-step mutations — those in the bank have distance 1.
# Generate all mutations for those; any of these mutations found in the bank will have distance 2.
# So on until either: (1) endGene is in the bank -> return the number of mutations, or (2) bank is empty -> return -1.
