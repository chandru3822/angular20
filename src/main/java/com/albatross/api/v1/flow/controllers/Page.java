package com.albatross.api.v1.flow.controllers;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.hateoas.EntityModel;

import java.util.Collection;

@Data
@RequiredArgsConstructor
public class Page<T> extends EntityModel<Page<T>> {
    private final Collection<T> results;

    public int size() {
        return results.size();
    }
}
