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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="sventon-ui" uri="/WEB-INF/sventon.tld" %>

<c:forEach items="${svndir}" var="entry">
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

  <tr class="sventonFileEntryTableRow expandedDir${rowNumber}">
    <td class="sventonCol1">
      <input type="checkbox" name="entries" value="${entry.fullEntryName}@${entry.revision}">
    </td>
    <td class="sventonCol2">
      <div id="${entryTrayAddUrl}" class="entry">
        <sventon-ui:fileTypeIcon filename="${entry.name}"/>
      </div>
    </td>
    <td class="sventonCol3">
      <a href="${showFileUrl}">${entry.name}</a>
    </td>
    <td class="sventonCol4"/>
    <td class="sventonCol5">${entry.size}</td>
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
</c:forEach>
