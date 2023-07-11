package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.NotificationType;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.SmsPriority;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.queries.NoteQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class NoteService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final CommunicationService communicationService;
  private final ContactService contactService;
  private final ProjectService projectService;
  private final UserService userService;

  @Value("${app.home_url}")
  private String homeUrl;

  public List<Note> getProjectProcessStepWorkQueueNotes(
      Long projectProcessStepId, Long processStepWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("processStepWorkQueueTypeId", processStepWorkQueueTypeId);
    return sqlCache.queryBySql(
      NoteQuery.getProjectProcessStepWorkQueueNotes, params, new NoteMapper<>(Note.class, om));
  }

  public Note getNote(Long noteId, String tableName) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", noteId);
    // currently won't return child notes. this is only called when saving a new note so it doesn't
    // matter, but would matter later on
    String sql = NoteQuery.getNote;
    sql = sql.replace("%TABLE_NAME%", tableName);
    return sqlCache.getBySql(sql, params, Note.class).orElse(null);
  }

  public Note saveNote(
      Long typeId,
      Note note,
      Boolean isPpsWqtNote,
      Boolean isPpsEventWqtNote,
      Boolean isProjectProdStats) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("typeId", typeId);
    params.put("note", note.getNote());
    // parentId is used for a hierarchy of notes - currently we don't use it
    params.put("parentId", note.getParentId());
    params.put("followUpDate", note.getFollowUpDate());
    params.put("userId", currentUser.trueUserId());

    // @randa: Would an upsert be better here? -- i dont think so because there is not a unique
    // constraint i could throw on it.  the same user can add multiple notes to the same
    // project/contact/user/etc
    Long noteId = null;
    Note fetchedNote = new Note();
    String tableName = isPpsWqtNote ? "project_process_step_process_step_work_queue_type_note" :
      isPpsEventWqtNote ? "pps_event_process_step_event_work_queue_type_note" :
        isProjectProdStats ? "project_prod_stats_note" : null;

    if (tableName != null) {
      if (null != note.getId()) {
        noteId = note.getId();
        params.put("id", noteId);
        String sql = NoteQuery.updateNote;
        sql = sql.replace("%TABLE_NAME%", tableName);
        sqlCache.updateBySql(sql, params);
      } else {

        if (isPpsWqtNote) {
          params.put("projectProcessStepId", note.getProjectProcessStepId());
          params.put("processStepWorkQueueTypeId", note.getProcessStepWorkQueueTypeId());
          params.put("typeId", typeId);
          noteId = sqlCache.updateBySqlReturningId(NoteQuery.insertProjectProcessStepWorkQueueNote, params, "id").longValue();
        } else if (isPpsEventWqtNote) {
          params.put("projectProcessStepEventId", note.getProjectProcessStepEventId());
          params.put("processStepEventWorkQueueTypeId", note.getProcessStepEventWorkQueueTypeId());
          params.put("typeId", typeId);
          noteId = sqlCache.updateBySqlReturningId(NoteQuery.insertProjectProcessStepEventWorkQueueNote, params, "id").longValue();
        } else if (isProjectProdStats) {
          // isProjectProdStats is used for Installer Dashboard
          params.put("projectId", note.getPrimaryId());
          params.put("productionType", note.getInstallDashTile());
          noteId = sqlCache.updateBySqlReturningId(NoteQuery.insertProjectProdStatsNote, params, "id").longValue();
        }
      }

      fetchedNote = getNote(noteId, tableName);
      fetchedNote.setPrimaryId(note.getPrimaryId());

      try (InputStream inputStream =
             NoteService.class.getResourceAsStream(
               "/communication/templates/note-mention-email.ftl.html")) {

        // Match for firstName lastName (Email)
        Pattern mentionedNameRegex = Pattern.compile("\\B@([a-zA-Z-\\s*()]+)\\s(\\S+) \\(([^)]+)\\)");
        Matcher m = mentionedNameRegex.matcher(fetchedNote.getNote());

        if (inputStream == null) {
          throw new RuntimeException("[Note] Unable to find template");
        }
        String template = IOUtils.toString(inputStream, Charset.defaultCharset());

        // If mention(s) are found in the Note
        while (m.find()) {
          String firstName = m.group(1);
          String lastName = m.group(2);
          String emailAddress = m.group(3);

          String locationOfNote = "";
          String link = "";
          // Used to store the Contact name or Project name which contains the Note
          String noteRefName = "";
          if (null != typeId && typeId.equals(ObjectType.CONTACT.id)) {
            locationOfNote = "contact";
            link = homeUrl + "/contact/" + note.getPrimaryId();
            Contact c = contactService.getContact(note.getPrimaryId());
            noteRefName = c.getFirstName() + " " + c.getLastName() + " - " + c.getId();
          } else if (null != typeId && typeId.equals(ObjectType.PROJECT.id)) {
            locationOfNote = "project";
            link = homeUrl + "/project/" + note.getPrimaryId() + "/details";
            Optional<Project> p = projectService.getProject(note.getPrimaryId());
            if (p.isPresent()) {
              noteRefName = p.get().getProjectName() + " - " + p.get().getId();
            }
          }

          User mentionedUser = userService.findByUsernameOrEmailIgnoreCase(emailAddress);
          if (mentionedUser != null) {
            if (NotificationType.EMAIL.id.equals(mentionedUser.getNotificationTypeId())) {
              Map<String, Object> context = new HashMap<>();
              context.put("firstName", firstName);
              context.put("lastName", lastName);
              context.put("locationOfNote", locationOfNote);
              context.put("link", link);
              context.put("noteContents", note.getNote());
              String emailSubject =
                currentUser.getFirstName()
                  + " "
                  + currentUser.getLastName()
                  + " mentioned you in a note on "
                  + noteRefName;
              communicationService.sendEmail(
                emailSubject,
                emailAddress,
                template,
                context,
                "noreply@albatross.myblueraven.com",
                "Albatross",
                currentUser.trueUserId(),
                null);
            } else {
              String groupId = UUID.randomUUID().toString();
              String textMessage =
                "You were mentioned in an Albatross note. Click here: "
                  + link
                  + " to open the "
                  + locationOfNote
                  + ".";
              communicationService.queueTextMessages(
                groupId, mentionedUser, textMessage, null, currentUser.trueUserId(), SmsPriority.NOTE_MENTION.level);
            }
          } else {
            log.warn("NOTE: Unable to find user account associated to email={}", emailAddress);
          }
        }
      } catch (IOException e) {
        log.error("NOTE: Error sending user mention email", e);
      }

    }
    return fetchedNote;
  }

  public void deleteNote(Long noteId, String tableName) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("noteId", noteId);
    params.put("modifiedById", currentUser.trueUserId());

    String sql = NoteQuery.deleteNote;
    sql = sql.replace("%TABLE_NAME%", tableName);
    sqlCache.updateBySql(sql, params);
  }

  public void saveNoteTimer(InteractionTimer noteTimer){
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("projectId", noteTimer.getProjectId());
    params.put("startTimestamp", noteTimer.getStartTimestamp());
    params.put("endTimestamp", noteTimer.getEndTimestamp());
    params.put("startEvent", noteTimer.getStartEvent());
    params.put("endEvent", noteTimer.getEndEvent());
    params.put("timerType", noteTimer.getTimerType());
    sqlCache.updateBySql(NoteQuery.insertNoteTimer, params);
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
      bw.registerCustomEditor(
          List.class, "childNotes", new JsonCollectionDeserializer(childNoteRef, objectMapper));

      TypeReference<UserPosition> createdByPrimaryPositionRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          Object.class,
          "createdByPrimaryPosition",
          new JsonCollectionDeserializer(createdByPrimaryPositionRef, objectMapper));
    }
  }
}
