package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;
import org.springframework.boot.jackson.JsonComponent;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class UserAccountDetails implements UserDetails {

    private static final long serialVersionUID = 0L;

    private Long id;
    private String username;
    @JsonIgnore
    private String password;
    @JsonIgnore
    private boolean accountNonExpired, accountNonLocked, credentialsNonExpired, enabled;
    private String firstName, lastName, fullName, awsBucket, companyAbbreviation;
    private Long masqueradeId, companyId, parentCompanyId, highestParentCompanyId;
    private Set<GrantedAuthority> authorities;

    public UserAccountDetails() {
    }

    public UserAccountDetails(User user, List<UserPermission> permissions) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.password = user.getPassword();
        this.firstName = user.getFirstName();
        this.lastName = user.getLastName();
        this.fullName = user.getFullName();
        this.awsBucket = user.getAwsBucket();
        this.companyId = user.getCompanyId();
        this.parentCompanyId = user.getParentCompanyId();
        // parent = true parent, highest = max in a company tier
        this.highestParentCompanyId = user.getHighestParentCompanyId();
        this.companyAbbreviation = user.getCompanyAbbreviation();

        // TODO: determine expired, lock, enabled, etc.
        this.accountNonExpired = true;
        this.accountNonLocked = true;
        this.credentialsNonExpired = true;
        this.enabled = true;

        this.authorities = new HashSet<>();
        for (UserPermission userPermission : permissions) {
            this.authorities.add(new SimpleGrantedAuthority(userPermission.getPermissionName()));
        }
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    public Long getId() {
        return id;
    }

    /**
     * The ID of the current user within context of business logic, such as masquerading / etc; useful for
     * pulling data when pretending to be someone else.
     */
    public Long getEffectiveId(){
        return masqueradeId != null ? masqueradeId : id;
    }

    /**
     * The ID of the current user, regardless of masquerading / etc; useful for auditing
     */
    public Long getAbsoluteId(){
        return id;
    }

    @Override
    @JsonIgnore
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return accountNonExpired;
    }

    @Override
    public boolean isAccountNonLocked() {
        return accountNonLocked;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return credentialsNonExpired;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }

    public Long getMasqueradeId() {
        return masqueradeId;
    }

    public String getAwsBucket() {
        return awsBucket;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public String getFullName() {
        return fullName;
    }

    public void setMasqueradeId(Long masqueradeId) {
        this.masqueradeId = masqueradeId;
    }

    public void setAwsBucket(String awsBucket) {
        this.awsBucket = awsBucket;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }

    public Long getParentCompanyId() {
        return parentCompanyId;
    }

    public void setParentCompanyId(Long parentCompanyId) {
        this.parentCompanyId = parentCompanyId;
    }

    public Long getHighestParentCompanyId() {
        return highestParentCompanyId;
    }

    public void setHighestParentCompanyId(Long highestParentCompanyId) {
        this.highestParentCompanyId = highestParentCompanyId;
    }

    @JsonComponent
    public static class GrantedAuthorityJsonSerialized extends JsonSerializer<GrantedAuthority> {

        @Override
        public void serialize(GrantedAuthority grantedAuthority, JsonGenerator jsonGenerator, SerializerProvider serializerProvider) throws IOException, JsonProcessingException {
            jsonGenerator.writeString(grantedAuthority.getAuthority());
        }
    }
}
