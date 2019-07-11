package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class AttachmentService {

  @Autowired
  SqlCache sqlCache;

  public List<AttachmentType> getAttachmentTypesForCompany(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);

    List<AttachmentType> attachmentTypes = sqlCache.query("attachment.getTypesForCompany", params, AttachmentType.class);
    return attachmentTypes;
  }

  public Optional<AttachmentType> getType(Long companyId, Long typeId) {
    return sqlCache.get("attachment.getType",
        ImmutableMap.of("companyId", companyId,
            "typeId", typeId),
        AttachmentType.class);
  }

  public void deleteType(Long typeId) {
    sqlCache.update("attachment.deleteType",
        ImmutableMap.of("id", typeId));
  }

  public void updateType(AttachmentType attachmentType) {
    sqlCache.update("attachment.updateType",
        ImmutableMap.of("companyId", attachmentType.getCompanyId(),
            "id", attachmentType.getId(),
            "attachmentType", attachmentType.getAttachmentType()));
  }

  public Optional<AttachmentType> insertType(AttachmentType type) {
    Long id = sqlCache.updateReturningId("attachment.insertType",
        ImmutableMap.of("attachmentType", type.getAttachmentType(),
            "companyId", type.getCompanyId()),
        "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
