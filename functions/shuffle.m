function shuffled = shuffle(unshuffled)

    shuffledIndices = randperm(size(unshuffled,2),size(unshuffled,2));
    shuffled = unshuffled(shuffledIndices);

