package com.albatross.api.v1.flow.services;

import com.albatross.api.config.ScheduledConfig;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.NotificationType;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
public class NoteService {

  @Value("${app.home_url}")
  private String homeUrl;

  @Autowired
  private CommunicationService communicationService;

  @Autowired
  private ContactService contactService;

  @Autowired
  private ProjectService projectService;

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  private UserService userService;

  @Autowired
  ObjectMapper om;

  public List<Note> getByPrimaryAndType(Long typeId, Long primaryId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("typeId", typeId);
    params.put("primaryId", primaryId);
    params.put("companyId", currentUser.getCompanyId());
    List<Note> results = sqlCache.query("note.getByPrimaryAndType", params, new NoteMapper<>(Note.class, om));
    return results;
  }

  public List<Note> getProjectProcessStepWorkQueueNotes(Long projectProcessStepId, Long processStepWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("processStepWorkQueueTypeId", processStepWorkQueueTypeId);
    List<Note> results = sqlCache.query("note.getProjectProcessStepWorkQueueNotes", params, new NoteMapper<>(Note.class, om));
    return results;
  }

  public Note getNote(Long noteId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", noteId);
    //currently won't return child notes. this is only called when saving a new note so it doesn't matter, but would matter later on
    Optional<Note> result = sqlCache.get("note.getNote", params, Note.class);
    return result.orElse(null);
  }

  public Note saveNote(Long typeId, Note note) {
    return saveNote(typeId, note, false, false, false);
  }

  public Note saveNote(Long typeId, Note note, Boolean isPpsWqtNote, Boolean isPpsEventWqtNote, Boolean isProjectProdStats) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("typeId", typeId);
    params.put("note", note.getNote());
    // parentId is used for a hierarchy of notes - currently we don't use it
    params.put("parentId", note.getParentId());
    params.put("followUpDate", note.getFollowUpDate());
    params.put("userId", currentUser.trueUserId());

    // @randa: Would an upsert be better here? -- i dont think so because there is not a unique constraint i could throw on it.  the same user can add multiple notes to the same project/contact/user/etc
    Long noteId;
    if(null != note.getId()) {
      noteId = note.getId();
      params.put("id", noteId);
      sqlCache.update("note.updateNote", params);
    } else {
      noteId = sqlCache.updateReturningId("note.insertNote", params, "id").longValue();

      HashMap<String, Object> p2 = new HashMap<>();
      if(isPpsWqtNote) {
        p2.put("projectProcessStepId", note.getProjectProcessStepId());
        p2.put("processStepWorkQueueTypeId", note.getProcessStepWorkQueueTypeId());
        p2.put("noteId", noteId);
        p2.put("typeId", typeId);
        sqlCache.update("note.insertProjectProcessStepWorkQueueNoteRelation", p2);
      } else if(isPpsEventWqtNote) {
        p2.put("projectProcessStepEventId", note.getProjectProcessStepEventId());
        p2.put("processStepEventWorkQueueTypeId", note.getProcessStepEventWorkQueueTypeId());
        p2.put("noteId", noteId);
        p2.put("typeId", typeId);
        sqlCache.update("note.insertProjectProcessStepEventWorkQueueNoteRelation", p2);
      }else if(isProjectProdStats) {
        // isProjectProdStats is used for Installer Dashboard
        p2.put("projectId", note.getPrimaryId());
        p2.put("productionType", note.getInstallDashTile());
        p2.put("noteId", noteId);
        sqlCache.update("note.insertProjectProdStatsNoteRelation", p2);
      } else {
        //add to the glue table only if it is a new note
        p2.put("primaryId", note.getPrimaryId());
        p2.put("noteId", noteId);
        p2.put("typeId", typeId);
        sqlCache.query("note.insertNoteRelation", p2, String.class);
      }
    }

    Note fetchedNote = getNote(noteId);
    fetchedNote.setPrimaryId(note.getPrimaryId());
    // Match for firstName lastName (Email)
    Pattern mentionedNameRegex = Pattern.compile("\\B@([a-zA-Z-\\s*()]+)\\s(\\S+) \\(([^)]+)\\)");
    Matcher m = mentionedNameRegex.matcher(fetchedNote.getNote());
    // If mention(s) are found in the Note
    while (m.find()) {
      String firstName = m.group(1);
      String lastName = m.group(2);
      String emailAddress = m.group(3);

      try {
        InputStream inputStream = ScheduledConfig.class.getResourceAsStream("/communication/templates/note-mention-email.ftl.html");
        String template = IOUtils.toString(inputStream);

        String locationOfNote = "";
        String link = "";
        // Used to store the Contact name or Project name which contains the Note
        String noteRefName = "";
        if (null != typeId && typeId.equals(ObjectType.CONTACT.id)) {
          locationOfNote = "contact";
          link = homeUrl + "/contact/" + note.getPrimaryId();
          Contact c = contactService.getContact(note.getPrimaryId());
          noteRefName = c.getFirstName() + " " + c.getLastName() + " - " + c.getId();
        }
        else if (null != typeId && typeId.equals(ObjectType.PROJECT.id)) {
          locationOfNote = "project";
          link = homeUrl + "/project/"+note.getPrimaryId()+"/details";
          Optional<Project> p = projectService.getProject(note.getPrimaryId());
          if (p.isPresent()) {
            noteRefName = p.get().getProjectName() + " - " + p.get().getId();
          }
        }

        // Check if text message or email
        User mentionedUser = userService.findByUsernameOrEmailIgnoreCase(emailAddress);
        if (mentionedUser.getNotificationTypeId() == NotificationType.EMAIL.id) {
          HashMap context = new HashMap();
          context.put("firstName", firstName);
          context.put("lastName", lastName);
          context.put("locationOfNote", locationOfNote);
          context.put("link", link);
          context.put("noteContents", note.getNote());
          String emailSubject = currentUser.getFirstName() + " " + currentUser.getLastName() +
            " mentioned you in a note on " + noteRefName;
          communicationService.sendEmail(emailSubject, emailAddress, template, context, "noreply@albatross.myblueraven.com", "Albatross", currentUser.trueUserId());
        }
        else {
          String groupId = UUID.randomUUID().toString();
          String textMessage = "You were mentioned in an Albatross note. Click here: " + link + " to open the " + locationOfNote + ".";
          communicationService.queueTextMessages(groupId, mentionedUser, textMessage, null, currentUser.trueUserId());
        }
      } catch (IOException e) {
        log.error("NOTE: Error sending user mention email {}", e.getMessage());
        e.printStackTrace();
      }
    }

    return fetchedNote;
  }

  public void deleteNote(Long noteId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("noteId", noteId);

    params.put("modifiedById", currentUser.trueUserId());
    sqlCache.update("note.deleteNote", params);
  }

  public static class NoteMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public NoteMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Note>> childNoteRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "childNotes",
          new JsonCollectionDeserializer(childNoteRef, objectMapper));

      TypeReference<UserPosition> createdByPrimaryPositionRef = new TypeReference<>() {};
      bw.registerCustomEditor(Object.class, "createdByPrimaryPosition",
        new JsonCollectionDeserializer(createdByPrimaryPositionRef, objectMapper));

    }
  }

}
