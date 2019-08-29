package com.albatross.api.v1.flow.services;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.RequiredArgsConstructor;


@Getter
@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
public class Pagination {
    public static Pagination fromPageSize(int page, int size) {
        return new Pagination(page, size);
    }

    public static Pagination fromOffsetLimit(int offset, int limit) {
        return new Pagination(offset/limit, limit);
    }

    private final int page, size;

    public int getStartOffset() {
        return page * size;
    }

    public int getSize() {
        return size;
    }
}
