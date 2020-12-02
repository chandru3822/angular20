package com.albatross.api.security.excel;

import com.albatross.api.security.SecurityService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class UserBasicAuthProvider extends GenericBasicAuthProvider {
    @Autowired
    private final SecurityService securityService;

    @Override
    protected boolean areValidCreds(String username, String password) {
        return Optional.ofNullable(securityService.getUser(username))
                       .map(user -> securityService.validatePassword(user, password))
                       .orElse(false);
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return securityService.loadUserByUsername(username);
    }
}
