package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials;

import com.albatross.api.pdf.PdfService;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPart;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.query.BillOfMaterialsQuery;
import com.albatross.api.v1.company.blueraven.controllers.proposal.BlueravenProposalService;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.services.ContactService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class BillOfMaterialsService {

    private final SecurityService securityService;
    private final SqlCache sqlCache;
    private final ObjectMapper om;
    private final BlueravenProposalService blueravenProposalService;
    private final ContactService contactService;
    private final ProjectService projectService;
    private final PdfService pdfService;

    @Transactional
    public List<BillOfMaterialsPart> upsertBomParts(Long projectId, List<BillOfMaterialsPart> parts){
        //the passed in list of parts should be only the parts that have somehow changed;
        // we can then simply update their quantity, whether they're archived, and their dateModified/modifiedById
        User user = securityService.getCurrentUser();

        //do a batch update using upsertBomParts
        final List<Map<String, Object>> insertParams =
                parts.stream().filter(p ->p.getId() == null).map(p -> {
                    final Map<String, Object> map = new HashMap<>();
                    map.put("userId", user.getId());
                    map.put("id", p.getId());
                    map.put("quantity", p.getQuantity());
                    map.put("partsMasterId", p.getPartsMasterId());
                    map.put("projectId", projectId);
                    map.put("supplierId", p.getSupplierId());
                    map.put("supplierConfirmed", p.getSupplierConfirmed() != null && p.getSupplierConfirmed()); //if no value for supplierConfirmed, then false
                    Boolean archived = p.getQuantity() <= 0 || p.getArchived() != null && p.getArchived(); //make sure if they set the quantity to zero the part gets archived
                    map.put("archived", archived);
                    return map;
                }).toList();

        final List<Map<String, Object>> updateParams =
                parts.stream().filter(p ->p.getId() != null).map(p -> {
                    final Map<String, Object> map = new HashMap<>();
                    map.put("userId", user.getId());
                    map.put("id", p.getId());
                    map.put("quantity", p.getQuantity() == 0 ? null : p.getQuantity());
                    map.put("partsMasterId", p.getPartsMasterId());
                    map.put("projectId", projectId);
                    map.put("supplierId", p.getSupplierId());
                    map.put("supplierConfirmed", p.getSupplierConfirmed() != null && p.getSupplierConfirmed()); //if no value for supplierConfirmed, then false
                    Boolean archived = (p.getQuantity()!= null && p.getQuantity() <= 0) || p.getArchived() != null && p.getArchived(); //make sure if they set the quantity to zero the part gets archived
                    map.put("archived", archived);
                    return map;
                }).toList();

        if(insertParams.size() > 0) {
            sqlCache.updateBatchBySql(BillOfMaterialsQuery.insertBomParts, insertParams);
        }
        if(updateParams.size() > 0) {
            sqlCache.updateBatchBySql(BillOfMaterialsQuery.updateBomParts, updateParams);
        }
        return getBomForProject(projectId);
    }

    public List<BillOfMaterialsPart> getBomForProject(Long projectId){
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);

        return sqlCache.queryBySql(BillOfMaterialsQuery.getBomForProject, params, BillOfMaterialsPart.class);
    }

    public void deleteBillOfMaterialsAllParts(Long projectId){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", user.getId());
        params.put("projectId", projectId);

        sqlCache.updateBySql(BillOfMaterialsQuery.deleteAllBomParts, params);
    }

    public Resource generateMaterialListPDF (Long projectId, List<BillOfMaterialsPart> parts){

//        get design log number
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);
        Long designLogNumber = sqlCache.getBySql(BillOfMaterialsQuery.getDesignLogNumber, params, new SingleColumnRowMapper<>(Long.class)).orElse(null);
//        get permit pack log number
        Long permitPackLogNumber = sqlCache.getBySql(BillOfMaterialsQuery.getPermitPackLogNumber, params, new SingleColumnRowMapper<>(Long.class)).orElse(null);
//        get project/contact? name, address, phone number
        Project project = projectService.getProject(projectId).orElse(new Project());
        String address = buildAddress(project.getStreet1(), project.getStreet2(), project.getCity(), project.getState(), project.getPostalCode());

        String htmlStart = """
                <!DOCTYPE html>
                  <head>
                    <title>Sample PDF</title>
                    <style>
                      body {
                        font-family: Lato, sans-serif;
                        text-align: center;
                      }
                      h1 {
                        color: #333;
                      }
                    </style>
                  </head>
                  <body>
                  <h1> Blue Raven Solar</h1>
                  <div>1403 N Research Way, Building J</div>
                  <div>Orem, UT 84097</div>
                  <div>800-377-4480</div>
                """;
        String htmlContent = htmlStart.concat("<div>Project ID " + projectId + "</div>");
        htmlContent = htmlContent.concat("<div>Date " + "</div>");
        htmlContent = htmlContent.concat("<div>Final Design Log Number " + (designLogNumber==null ? "" : designLogNumber) + "</div>");
        htmlContent = htmlContent.concat("<div>Permit Pack Log Number " + (permitPackLogNumber==null ? "" : permitPackLogNumber) + "</div>");
        htmlContent = htmlContent.concat("<h2>Ship to </h2>");
        htmlContent = htmlContent.concat(createDiv("Name: " + project.getProjectName()));
        htmlContent = htmlContent.concat(createDiv("Address: " + address));
        htmlContent = htmlContent.concat(createDiv("Phone Number: " + project.getPhone()));
        BillOfMaterialsPart part = parts.get(0);
        htmlContent = htmlContent.concat(createDiv(part.getDescription() + " " + part.getBrand() + " " + part.getQuantity() + " " + part.getPartNumber()));

        htmlContent = htmlContent.concat("  </body></html>");
//        generate pdf with all info
       return pdfService.convert(htmlContent);
    }

    public String buildAddress(String street1, String street2, String city, String state, String zip) {
        StringBuilder sb = new StringBuilder(street1);
        if(street2 != null && street2.length() > 0){
            sb.append("<br/>").append(street2);
        }
        sb.append("<br/>").append(city).append(", ").append(state).append(" ").append(zip);
        return sb.toString();
    }

    public String createDiv (String content){
        return "<div>" + content + "</div>";
    }
}
