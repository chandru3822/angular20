package com.albatross.api.utils;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import java.util.List;
import java.util.Map;

/**
 * Created by dave on 4/27/17.
 */
public class Params extends ImmutableMap.Builder<String, Object> {

    private List<String> nulled = Lists.newArrayList();

    public Params() {
        super();
    }

    public Params(String key, Object value){
        this();
        this.put(key, value);
    }

    @Override
    public Params put(String key, Object value) {
        if( value == null ){
            nulled.add(key);
            return this;
        }else{
            //remove entry if it's added later
            if (nulled.contains(key)){
                nulled.remove(key);
            }
        }
        super.put(key, value);
        return this;
    }

    @Override
    public ImmutableMap.Builder<String, Object> put(Map.Entry<? extends String, ?> entry) {
        if( entry.getValue() == null ){
            nulled.add(entry.getKey());
            return this;
        }
        super.put(entry);
        return this;
    }

    public Map<String, Object> buildNullable() {
        ImmutableMap<String, Object> im = super.build();
        Map<String, Object> result = Maps.newHashMap(im);
        nulled.forEach( key -> result.put(key, null) );
        return result;
    }

    @Override
    @Deprecated
    public ImmutableMap<String, Object> build() {
        return super.build();
    }
}
