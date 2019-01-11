def qcheck(solution):
    blocked = [ [], [], [], [], [], [], [], [] ]
    for i in range(8):
        cur = solution[i]

        # if current row has been blocked, fail
        if cur in blocked[i]:
            return False

        # otherwise, block the rows below us
        for j in range(i + 1, 8):
            # block the column
            blocked[j].append(cur)
            # block the diagonal
            offset = j - i
            blocked[j].append(cur + offset)
            blocked[j].append(cur - offset)

    # if we make it through all of the above, pass
    return True
