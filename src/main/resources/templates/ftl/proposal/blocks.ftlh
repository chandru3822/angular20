<#macro kebabCase name>
  ${name?replace("([a-z])([A-Z]+)","$1-$2", "r")?lower_case?trim}
</#macro>

<#macro globalStyles styles={}>
<#if styles?has_content>
    <#list styles as cls, values>
      <@compress single_line=true>
      .${cls} {
          <#list values as key, value>
            <#outputformat "plainText">
              <#local cssClass><@kebabCase name=key/></#local>
            </#outputformat>
            <#if value?has_content>${cssClass?trim}:${value};</#if>
          </#list>
      }
      </@compress>
    </#list>
</#if>
</#macro>

<#macro inlineStyle styles={}>
<#if styles?has_content>
  <@compress single_line=true>
    style="<#list styles as key, value>
    <#outputformat "plainText">
      <#local styleName><@kebabCase name=key/></#local>
    </#outputformat>
    <#if value?has_content>${styleName?trim}:${value};</#if>
    </#list>"
  </@compress>
</#if>
</#macro>

<#macro addAttrs attrs={}>
  <#if attrs?has_content>
      <@compress single_line=true>
          <#list attrs as key, value>
            <#outputformat "plainText">
              <#local attrKey><@kebabCase name=key/></#local>
            </#outputformat>
              <#if value?has_content>
                  <#if value?is_sequence>
                      ${attrKey?trim}="${value?first}"
                  <#else>
                    ${attrKey?trim}="${value}"
                  </#if>
              </#if>
          </#list>
      </@compress>
  </#if>
</#macro>

<#macro bold><@compress single_line=true><strong><#nested /></strong></@compress></#macro>
<#macro italic><@compress single_line=true><em><#nested /></em></@compress></#macro>
<#macro strike><@compress single_line=true><s><#nested /></s></@compress></#macro>
<#macro superscript><@compress single_line=true><sup><#nested /></sup></@compress></#macro>

<#function addMarks aVal marks=[]>
    <#if marks?size lt 1 >
        <#return aVal>
    </#if>
    <#local type=marks[0].type>
    <#local val>
        <@.vars[type]>${aVal}</@>
    </#local>
    <#return addMarks(val, marks[1..])>
</#function>

<#macro horizontalRule node=""><hr /></#macro>
<#macro hardBreak node=""><br /></#macro>
<#macro text node>${addMarks(node.text, node.marks![])}</#macro>
<#macro mention node>
<#--  <#local fallback>#### ${node.attrs.id} #### </#local>-->
  <#local fallback></#local>
  ${addMarks(node.text!fallback, node.marks![])}
</#macro>

<#macro tableCell node>
  <td <@addAttrs attrs=node.attrs/>>
    <#list node.content as content>
        <@.vars[content.type] content/>
    </#list>
  </td>
</#macro>

<#macro tableHeader node>
  <th <@addAttrs attrs=node.attrs/>>
    <#list node.content as content>
      <@.vars[content.type] content/>
    </#list>
  </th>
</#macro>

<#macro tableRow node>
<#compress>
<tr <@addAttrs attrs=node.attrs/>>
    <#list node.content as content>
        <@.vars[content.type] content/>
    </#list>
</tr>
</#compress>
</#macro>

<#macro table node>
  <table <@addAttrs attrs=node.attrs/>>
    <tbody>
      <#list node.content as content>
          <@.vars[content.type] content/>
      </#list>
    </tbody>
  </table>
</#macro>

<#macro paragraph node>
<@compress single_line=true>
  <p <@inlineStyle styles=node.attrs/>>
    <#if node.content?has_content>
      <#list node.content as content><@.vars[content.type] content/></#list>
    </#if>
  </p>
</@compress>
</#macro>

<#macro heading node>
  <#local type=node.attrs.level!1>
  <@compress single_line=true>
    <h${type} <@addAttrs attrs=node.attrs/>><#list node.content as c>${addMarks(c.text, c.marks![])}</#list></h${type}>
  </@compress>
</#macro>

<#macro orderedList node>
  <#compress>
    <ol class="proposal-ordered-list" <@inlineStyle styles=node.blockStyle/>>
        <#list node.content as content><@.vars[content.type] content/></#list>
    </ol>
  </#compress>
</#macro>

<#macro bulletList node>
  <#compress>
    <ul class="proposal-bullet-list" <@inlineStyle styles=node.blockStyle/>>
        <#list node.content as content><@.vars[content.type] content/></#list>
    </ul>
  </#compress>
</#macro>

<#macro listItem node>
  <#compress>
    <li class="proposal-list-item" <@inlineStyle styles=node.blockStyle/>>
        <#list node.content as content><@.vars[content.type] content/></#list>
    </li>
  </#compress>
</#macro>

<#macro TextBlock node>
  <#compress>
    <div class="proposal-text ${node.themeKey!''}" <@inlineStyle styles=node.blockStyle/>>
        <#list node.blockValue.content as content>
            <@.vars[content.type] node=content/>
        </#list>
    </div>
  </#compress>
</#macro>

<#macro ImageBlock node>
  <@compress single_line=true>
    <div class="proposal-img ${node.themeKey!''}" <@inlineStyle styles=node.blockStyle/>>
      <img src="${node.blockValue.url}" alt="[Replace Me] An Image Block" />
    </div>
  </@compress>
</#macro>

<#macro PageBlock node="">
  <#compress>
    <div class="proposal-page ${node.themeKey!''}" <@inlineStyle styles=node.blockStyle/> data-order="${node.blockOrder}">
        <#nested />
    </div>
  </#compress>
</#macro>

<#macro ContainerBlock node="">
  <#compress><div class="proposal-container ${node.themeKey!''}" <@inlineStyle styles=node.blockStyle/>>
      <#nested />
    </div>
  </#compress>
</#macro>

<#macro builder parentId="" blocks=[]>
    <#if parentId?has_content>
        <#assign children=blocks?filter(b->(b.parentId!-1) == parentId)>
    <#else>
        <#assign children=blocks?filter(b->!b.parentId?has_content)>
    </#if>

    <#compress>
      <#list children?sort_by("blockOrder") as block>
          <#attempt>
              <@.vars[block.blockType] node=block>
                  <#if block.blockValue??> ${block.blockValue} </#if>
                  <@builder parentId=block.id blocks=blocks/>
              </@>
              <#recover>
                <div class="render-error" style="border: 1px dashed red; font-style: unset; white-space: pre; background: white; filter: opacity(.95)">
                  <h1>Whoops...</h1>
                  <code>${.error}</code>
                </div>
          </#attempt>
      </#list>
  </#compress>
</#macro>
