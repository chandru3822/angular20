package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Note;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
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
public class NoteService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<Note> getByPrimaryAndType(Long typeId, Long primaryId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("typeId", typeId);
    params.put("primaryId", primaryId);
    List<Note> results = sqlCache.query("note.getByPrimaryAndType", params, new NoteMapper<>(Note.class, om));
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
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("typeId", typeId);
    params.put("note", note.getNote());
    // parentId is used for a hierarchy of notes - currently we don't use it
    params.put("parentId", note.getParentId());
    params.put("userId", currentUser.getId());

    // @randa: Would an upsert be better here? -- i dont think so because there is not a unique constraint i could throw on it.  the same user can add multiple notes to the same project/contact/user/etc
    Long noteId;
    if(null != note.getId()) {
      noteId = note.getId();
      params.put("id", noteId);
      sqlCache.update("note.updateNote", params);
    } else {
      noteId = sqlCache.updateReturningId("note.insertNote", params, "id").longValue();

      //add to the glue table only if it is a new note
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("primaryId", note.getPrimaryId());
      p2.put("noteId", noteId);
      p2.put("typeId", typeId);
      sqlCache.query("note.insertNoteRelation", p2, String.class);
    }

    Note fetchedNote = getNote(noteId);
    fetchedNote.setPrimaryId(note.getPrimaryId());
    return fetchedNote;
  }

  public void deleteNote(Long noteId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("noteId", noteId);

    params.put("modifiedById", currentUser.getId());
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

    }
  }

}
