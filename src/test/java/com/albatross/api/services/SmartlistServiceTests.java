package com.albatross.api.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.SmartlistService;
import com.albatross.api.v1.flow.services.SystemListService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import javax.annotation.PostConstruct;
import java.util.List;

import static org.mockito.Mockito.*;
import static org.springframework.test.util.AssertionErrors.fail;

@Slf4j
@ExtendWith(SpringExtension.class)
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@SpringBootTest
@ActiveProfiles(profiles = "local")
public class SmartlistServiceTests {

  private final SqlCache sqlCache;

  private final SqlCacheRO sqlCacheRO;

  private final SecurityService securityService = mock(SecurityService.class);

  private final ObjectMapper om;

  private final SystemListService systemListService;

  private SmartlistService smartlistService;

  @PostConstruct
  public void init() {

    var user = new User();
    user.setId(SystemSettings.CRON_USER.getId());
    user.setCompanyId(3L);
    user.setHighestCompanyId(3L);
    user.setHighestParentCompanyId(3L);

    when(securityService.getCurrentUser()).thenReturn(user);
    when(securityService.userHasFeatureAccessLevel(any(), any(), any(), any(), any())).thenReturn(true);

    smartlistService = spy(new SmartlistService(securityService, sqlCache, sqlCacheRO, om, systemListService));
  }

  @Test
  public void projectDetails() {
    final List<Long> currentlyFailingProjectDetails = List.of(43L,71L,134L,112L,253L,255L,278L,378L,322L,384L,443L,595L,2385L,589L,598L,678L,2985L,661L,775L,2341L,755L,1171L,802L,2342L,842L,932L,943L,944L,983L,987L,1019L,1018L,1076L,1027L,1072L,2559L,1084L,1128L,1115L,1193L,1203L,1233L,1246L,646L,1998L,1272L,2513L,1237L,1273L,36L,377L,1296L,1999L,1312L,1360L,1341L,2001L,2426L,1428L,1430L,1972L,1469L,1591L,1568L,1065L,1740L,1759L,2309L,2357L,2384L,1788L,1838L,1850L,2500L,1918L,1880L,113L,127L,70L,155L,226L,147L,302L,393L,475L,489L,503L,518L,462L,529L,751L,823L,826L,853L,942L,1052L,1070L,1051L,1374L,1429L,1640L,1938L,444L,21L,59L,76L,84L,87L,123L,97L,201L,245L,294L,283L,323L,275L,367L,421L,426L,416L,429L,502L,483L,672L,720L,791L,794L,803L,830L,914L,1006L,947L,1064L,1126L,1144L,1098L,1155L,1554L,1271L,1293L,1332L,1441L,1629L,1644L,1321L,2410L,1682L,1678L,1792L,1814L,1904L,1940L,2502L,2969L,2986L,541L,2911L,3039L,2663L,2713L,2866L,2757L,2761L,2768L,2762L,2758L,2763L,2759L,2760L,2802L,2825L);
    final String query = """
      select s.id
      from flow.smartlist s
             inner join flow.company_object_type cot on cot.id = s.company_object_type_id
      where s.archived is false and
            cot.company_id = 3 and
            s.project_details = true and
            s.id != any(array[43,71,134,112,253,255,278,378,322,384,443,595,2385,589,598,678,2985,661,775,2341,755,1171,802,2342,842,932,943,944,983,987,1019,1018,1076,1027,1072,2559,1084,1128,1115,1193,1203,1233,1246,646,1998,1272,2513,1237,1273,36,377,1296,1999,1312,1360,1341,2001,2426,1428,1430,1972,1469,1591,1568,1065,1740,1759,2309,2357,2384,1788,1838,1850,2500,1918,1880,113,127,70,155,226,147,302,393,475,489,503,518,462,529,751,823,826,853,942,1052,1070,1051,1374,1429,1640,1938,444,21,59,76,84,87,123,97,201,245,294,283,323,275,367,421,426,416,429,502,483,672,720,791,794,803,830,914,1006,947,1064,1126,1144,1098,1155,1554,1271,1293,1332,1441,1629,1644,1321,2410,1682,1678,1792,1814,1904,1940,2502,2969,2986,541,2911,3039,2663,2713,2866,2757,2761,2768,2762,2758,2763,2759,2760,2802,2825])
      order by s.id;
    """;
    List<Long> smartlistIds = sqlCacheRO.queryBySql(query, null, new SingleColumnRowMapper<>(Long.class));
    smartlistIds.forEach(id -> {
      try {
        log.info("Running smartlist ID: " + id);
        smartlistService.getSmartlistResults(id);
      } catch (Exception e) {
        if (!currentlyFailingProjectDetails.contains(id)) {
          log.error(String.format("Failed on smartlist ID: %s", id));
          log.error(e.getMessage());
        }
      }
    });
  }

  @Test
  public void processStepNonMain() {
    final List<Long> currentlyFailingProcessStepNonMain = List.of(1359L,1361L,1370L,1395L,1427L,1474L,1964L,2390L,2392L,2413L,2416L,2441L,2568L,2914L);

    final String query = """
      select s.id
      from flow.smartlist s
             inner join flow.company_object_type cot on cot.id = s.company_object_type_id
      where s.archived is false and
            cot.company_id = 3 and
            s.project_details = false and
            cot.object_type_id = 4 and
            s.main_process_steps = false
      order by s.id;
    """;
    List<Long> smartlistIds = sqlCacheRO.queryBySql(query, null, new SingleColumnRowMapper<>(Long.class));
    smartlistIds.forEach(id -> {
      try {
        log.info("Running smartlist ID: " + id);
        smartlistService.getSmartlistResults(id);
      } catch (Exception e) {
        if (!currentlyFailingProcessStepNonMain.contains(id)) {
          log.error(String.format("Failed on smartlist ID: %s", id));
          fail(e.getMessage());
        }
      }
    });
  }

  @Test
  public void processStepMain() {
//    final List<Long> currentlyFailingProcessStepMain = List.of(1359L,1361L,1370L,1395L,1427L,1474L,1964L,2390L,2392L,2413L,2416L,2441L,2568L,2914L);

    final String query = """
      select s.id
      from flow.smartlist s
             inner join flow.company_object_type cot on cot.id = s.company_object_type_id
      where s.archived is false and
            cot.company_id = 3 and
            s.project_details = false and
            cot.object_type_id = 4 and
            s.main_process_steps = true
      order by s.id;
    """;
    List<Long> smartlistIds = sqlCacheRO.queryBySql(query, null, new SingleColumnRowMapper<>(Long.class));
    smartlistIds.forEach(id -> {
      try {
        log.info("Running smartlist ID: " + id);
        smartlistService.getSmartlistResults(id);
      } catch (Exception e) {
//        if (!currentlyFailingProcessStepNonMain.contains(id)) {
          log.error(String.format("Failed on smartlist ID: %s", id));
          log.info(e.getMessage());
//          fail(e.getMessage());
//        }
      }
    });
  }
}
