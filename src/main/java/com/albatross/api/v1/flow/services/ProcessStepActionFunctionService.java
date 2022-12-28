package com.albatross.api.v1.flow.services;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@PreAuthorize("hasFeatureAccess('PROCESS_STEPS')")
public class ProcessStepActionFunctionService {

}
