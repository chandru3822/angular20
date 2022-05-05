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
  <#if node.content?has_content>
  <p <@inlineStyle styles=node.attrs/>>
    <#list node.content as content><@.vars[content.type] content/></#list>
  </p>
  </#if>
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

<#macro PlaceholderBlock node>
    <@compress single_line=true>
      <div class="proposal-img placeholder-img ${node.themeKey!''}" <@inlineStyle styles=node.blockStyle/>>
        <svg style="height: 100px; fill: #e0e2e8;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Pro 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. --><path d="M447.1 32h-384C28.64 32-.0091 60.65-.0091 96v320c0 35.35 28.65 64 63.1 64h384c35.35 0 64-28.65 64-64V96C511.1 60.65 483.3 32 447.1 32zM111.1 96c26.51 0 48 21.49 48 48S138.5 192 111.1 192s-48-21.49-48-48S85.48 96 111.1 96zM446.1 407.6C443.3 412.8 437.9 416 432 416H82.01c-6.021 0-11.53-3.379-14.26-8.75c-2.73-5.367-2.215-11.81 1.334-16.68l70-96C142.1 290.4 146.9 288 152 288s9.916 2.441 12.93 6.574l32.46 44.51l93.3-139.1C293.7 194.7 298.7 192 304 192s10.35 2.672 13.31 7.125l128 192C448.6 396 448.9 402.3 446.1 407.6z"/></svg>
        ${node.blockKind}
      </div>
    </@compress>
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
