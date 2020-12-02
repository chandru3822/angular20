package com.albatross.api.security.excel;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;

@Slf4j
public abstract class GenericBasicAuthProvider implements AuthenticationProvider, UserDetailsService {
    @Override
    public Authentication authenticate(Authentication auth) throws AuthenticationException {
        String username = auth.getPrincipal().toString();
        String password = auth.getCredentials().toString();

        log.debug("Attempting basic HTTP auth on user={}", username);
        if (areValidCreds(username, password)) {
            UserDetails user = loadUserByUsername(username);
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(username,
                    password, user.getAuthorities());
            return authentication;
        }

        // return null so that other AUthenticationProviders may run
        return null;
    }

    @Override
    public boolean supports(Class<?> c) {
        return UsernamePasswordAuthenticationToken.class.equals(c);
    }

    protected abstract boolean areValidCreds(String username, String password);
}
