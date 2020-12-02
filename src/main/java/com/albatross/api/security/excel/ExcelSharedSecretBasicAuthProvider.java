package com.albatross.api.security.excel;

import com.albatross.api.config.PropertiesConfiguration;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Component;

import java.util.ArrayList;

@Component
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ExcelSharedSecretBasicAuthProvider extends GenericBasicAuthProvider {
    private final PropertiesConfiguration props;

    @Override
    protected boolean areValidCreds(String username, String password) {
        return props.getExcelUser().equals(username)
                && props.getExcelPassword().equals(password);
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        if (props.getExcelUser().equals(username)) {
            return new User(username, props.getExcelPassword(), new ArrayList<>());
        }
        return null;
    }
}
