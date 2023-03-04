T[][] SplitChunks(T)(T[] arr, size_t chunkSize, T padding) {
	T[][]  ret = [[]];

	foreach (ref element ; arr) {
		ret[$ - 1] ~= element;

		if (ret[$ - 1].length >= chunkSize) {
			ret ~= (T[]).init;
		}
	}

	while (ret[$ - 1].length < chunkSize) {
		ret[$ - 1] ~= padding;
	}

	return ret;
}

T[] Pad(T)(T[] arr, size_t padTo, T padding) {
	T[] ret = arr;

	while (ret.length < padTo) {
		ret ~= padding;
	}

	return ret;
}
