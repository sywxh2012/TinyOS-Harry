<%
/*
 * ====================================================================
 * Copyright (c) 2005-2010 sventon project. All rights reserved.
 *
 * This software is licensed as described in the file LICENSE, which
 * you should have received as part of this distribution. The terms
 * are also available at http://www.sventon.org.
 * If newer versions of this license are posted there, you may use a
 * newer version instead, at your option.
 * ====================================================================
 */
%>
<%@ include file="/WEB-INF/jspf/pageInclude.jspf"%>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>

<html>
<head>
  <%@ include file="/WEB-INF/jspf/pageHead.jspf"%>
  <%@ include file="/WEB-INF/jspf/pageHeadRssLink.jspf"%>
  <title><spring:message code="window.title.default"/> - ${repositoryURL}</title>
</head>
<body>
  <%@ include file="/WEB-INF/jspf/pageTop.jspf"%>
  <sventon:currentTargetHeader title="repository.browser" target="${command.target}" properties="${properties}"/>

  <form name="searchForm" action="#" method="get" onsubmit="return doSearch(this, '${command.name}', '${command.path}');">
  <table class="sventonFunctionLinksTable">
    <tr>
      <td style="white-space: nowrap;">
        <sventon:browseFunctionButtons command="${command}"/>
        <c:choose>
          <c:when test="${useCache}">
            <sventon:flattenButton command="${command}" isHead="${isHead}" isUpdating="${isUpdating}"/>
          </c:when>
        </c:choose>
      </td>
      <td style="white-space: nowrap; text-align: right;"><spring:message code="filter.text"/></td>
      <td style="white-space: nowrap;">
        <sventon:extensionFilterList command="${command}" existingExtensions="${existingExtensions}" filterExtension="${filterExtension}"/>
      </td>
      <td style="text-align: right;">
        <c:if test="${useCache}">
          <sventon:searchField command="${command}" isUpdating="${isUpdating}" isHead="${isHead}" searchMode="${userRepositoryContext.searchMode}"/>
        </c:if>
      </td>
    </tr>
  </table>
    <!-- Needed by ASVNTC -->
    <input type="hidden" name="revision" value="${command.revision}">
  </form>

  <form:form method="post" action="#" name="entriesForm" onsubmit="return doAction(this, '${command.name}', '${command.path}');" commandName="command">
    <input type="hidden" name="revision" value="${command.revision}">
    <input type="hidden" name="pegRevision" value="${command.revisionNumber}">

    <c:url value="/repos/${command.name}/list${command.path}" var="sortUrl">
      <c:param name="revision" value="${command.revision}" />
    </c:url>

    <table class="sventonEntriesTable">
      <%@ include file="/WEB-INF/jspf/sortableEntriesTableHeaderRow.jspf"%>
      <c:set var="rowCount" value="0"/>
      <c:set var="totalSize" value="0"/>
      <c:set var="backLinkVisible" value="false"/>
      <c:if test="${command.path ne '/'}">
        <c:set var="backLinkVisible" value="true"/>
        <c:url value="/repos/${command.name}/list${command.parentPath}" var="backUrl">
          <c:param name="revision" value="${command.revision}"/>
        </c:url>

        <tr class="sventonEntryEven">
          <td class="sventonCol1"/>
          <td class="sventonCol2"><img src="images/icon_folder.png" alt="dir"></td>
          <td class="sventonCol3">
            <a href="${backUrl}">..&nbsp;&nbsp;&nbsp;</a>
          </td>
          <td/>
          <td/>
          <td/>
          <td/>
          <td/>
        </tr>
        <c:set var="rowCount" value="${rowCount + 1}"/>
      </c:if>

      <c:forEach items="${svndir}" var="entry">
        <c:url value="/repos/${command.name}/list${entry.fullEntryName}/" var="listUrl">
          <c:param name="revision" value="${command.revision}" />
          <c:param name="bypassEmpty" value="true" />
        </c:url>
        <c:url value="/repos/${command.name}/show${entry.fullEntryName}" var="showFileUrl">
          <c:param name="revision" value="${command.revision}" />
        </c:url>
        <c:url value="/repos/${command.name}/info" var="showRevInfoUrl">
          <c:param name="revision" value="${entry.revision}" />
        </c:url>
        <c:url value="/ajax/${command.name}/entrytray${entry.fullEntryName}" var="entryTrayAddUrl">
          <c:param name="revision" value="${entry.revision}" />
          <c:param name="pegRevision" value="${command.revisionNumber}"/>
          <c:param name="action" value="add" />
        </c:url>

        <c:set var="totalSize" value="${totalSize + entry.size}"/>

        <tr class="${rowCount mod 2 == 0 ? 'sventonEntryEven' : 'sventonEntryOdd'}">
          <td class="sventonCol1">
            <input type="checkbox" name="entries" value="${entry.fullEntryName}@${entry.revision}"/>
          </td>
          <c:choose>
            <c:when test="${'DIR' eq entry.kind}">
              <td class="sventonCol2">
                <div id="${entryTrayAddUrl}" class="entry">
                  <img src="images/icon_folder.png" alt="dir">
                </div>
              </td>
              <td class="sventonCol3"><a href="${listUrl}">${entry.name}</a></td>
            </c:when>
            <c:otherwise>
              <td class="sventonCol2">
                <div id="${entryTrayAddUrl}" class="entry">
                  <sventon-ui:fileTypeIcon filename="${entry.name}"/>
                </div>
              </td>
              <td class="sventonCol3"><a href="${showFileUrl}">${entry.name}</a></td>
            </c:otherwise>
          </c:choose>
          <td class="sventonCol4" align="center">
            <c:set var="lock" value="${locks[entry.fullEntryName]}" scope="page"/>
            <c:if test="${!empty lock}">
              <jsp:useBean id="lock" type="org.sventon.model.DirEntryLock" />
              <span onmouseover="Tip('<table><tr><td><b>Owner</b></td><td><%=StringEscapeUtils.escapeJavaScript(lock.getOwner())%></td></tr><tr><td><b>Comment</b></td><td style=\'white-space: nowrap\'>${lock.comment}</td></tr><tr><td><b>Created</b></td><td style=\'white-space: nowrap\'><fmt:formatDate type="both" value="${lock.creationDate}" dateStyle="short" timeStyle="short"/></td></tr><tr><td><b>Expires</b></td><td style=\'white-space: nowrap\'><fmt:formatDate type="both" value="${lock.expirationDate}" dateStyle="short" timeStyle="short"/></td></tr></table>')"><img alt="Lock" src="images/icon_lock.png"></span>
            </c:if>
          </td>
          <td class="sventonCol5"><c:if test="${'FILE' eq entry.kind}">${entry.size}</c:if></td>
          <td class="sventonCol6">
            <a href="${showRevInfoUrl}" onmouseover="getLogMessage(${entry.revision}, '${command.name}', '<fmt:formatDate type="both" value="${entry.date}" dateStyle="short" timeStyle="short"/>');">
              ${entry.revision}
            </a>
          </td>
          <td class="sventonCol7">${entry.author}</td>
          <td class="sventonCol8">
            <span onmouseover="Tip('<sventon-ui:age date="${entry.date}"/>');">
              <fmt:formatDate type="both" value="${entry.date}" dateStyle="short" timeStyle="short"/>
            </span>
          </td>
        </tr>
        <c:set var="rowCount" value="${rowCount + 1}"/>
      </c:forEach>

      <tr class="${rowCount mod 2 == 0 ? 'sventonEntryEven' : 'sventonEntryOdd'}">
        <td colspan="2" class="sventonCol1" align="right"><b><spring:message code="total"/>:</b></td>
        <td><b>${backLinkVisible ? rowCount - 1 : rowCount} <spring:message code="entries"/></b></td>
        <td/>
        <td align="right" title="${totalSize} bytes"><b><sventon-ui:formatBytes size="${totalSize}" locale="${pageContext.request.locale}"/></b></td>
        <td/>
        <td/>
        <td/>
      </tr>
      <tr class="entriesTableFooter">
        <%@ include file="/WEB-INF/jspf/actionSelectList.jspf"%>
        <td colspan="5"/>
      </tr>
    </table>
  </form:form>

  <c:if test="${bypassed}">
    <script type="text/javascript">
      new Effect.Highlight($('clickableUrl'), {startcolor: '#ffff00', restorecolor: 'true', duration: 3});
    </script>
  </c:if>

  <c:if test="${isEntryTrayEnabled}">
    <%@ include file="/WEB-INF/jspf/entryTray.jspf"%>
  </c:if>

<%@ include file="/WEB-INF/jspf/pageFoot.jspf"%>
</body>
</html>
