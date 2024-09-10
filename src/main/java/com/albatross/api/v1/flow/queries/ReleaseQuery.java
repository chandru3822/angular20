package com.albatross.api.v1.flow.queries;

public class ReleaseQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select r.id,
              r.release_name,
              r.stage_lock_date,
              r.uat_lock_date,
              r.release_date,
              r.archived
       from brs.release r
       where r.archived is not true
       order by r.release_date
    """;

  //language=PostgreSQL
  public final static String getOneRelease = """
    select r.id,
           r.release_name,
           r.stage_lock_date,
           r.uat_lock_date,
           r.release_date,
           r.archived
    from brs.release r
    where r.id = :id
    """;

  public final static String getNextRelease = """
      select r.id,
             r.release_name,
             r.stage_lock_date,
             r.uat_lock_date,
             r.release_date,
             r.archived
      from brs.release r
      where r.release_date > NOW()
      and r.archived is false
      order by r.release_date asc
      limit 1
    """;

  //language=PostgreSQL
  public final static String insertRelease = """
    insert into brs.release(release_name, stage_lock_date, uat_lock_date, release_date, archived, date_created, date_modified, created_by_id, modified_by_id)
     values (:name, :stageLockDate, :uatLockDate, :releaseDate, false, NOW(), NOW(), :userId, :userId)
    """;

  //language=PostgreSQL
  public final static String updateRelease = """
    update brs.release
        set release_name = :name,
            stage_lock_date = :stageLockDate,
            uat_lock_date = :uatLockDate,
            release_date = :releaseDate,
            archived = :archived,
            date_modified = NOW(),
            modified_by_id = :userId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteRelease = """
    update brs.release
        set archived = true
    where id = :id
    """;

}
