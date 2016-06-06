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
<%@ tag body-content="empty" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ attribute name="repositoryName" required="true" type="org.sventon.model.RepositoryName" %>
<%@ attribute name="repositoryNames" required="true" type="java.util.Set" %>
<%@ attribute name="isLoggedIn" required="true" type="java.lang.Boolean" %>
<%@ attribute name="isEditableConfig" required="true" type="java.lang.Boolean" %>

<table class="sventonHeader">
  <tr>
    <td>
      <spring:message code="sventon.header"/> -
      <a class="sventonHeaderLink" href="http://www.wandisco.com" target="page">WANdisco.com</a>
    </td>
    <td align="right">
      <c:if test="${(not empty repositoryNames && fn:length(repositoryNames) > 1) or isLoggedIn or isEditableConfig}">
        <c:url value="/repos/list" var="changeReposUrl"/>
        <c:url value="/repos/list" var="logoutUrl">
          <c:param name="logout" value="true"/>
          <c:param name="repositoryName" value="${repositoryName}"/>
        </c:url>
        <c:url value="/repos/listconfigs" var="adminUrl"/>
        <select class="sventonSelect" onchange="document.location.href=this.options[this.selectedIndex].value;">        
          <option class="sventonSelectOption"><spring:message code="actions"/></option>
          <c:if test="${isLoggedIn}">
            <option value="${logoutUrl}"><spring:message code="logout"/></option>
          </c:if>
          <c:if test="${not empty repositoryNames && fn:length(repositoryNames) > 1}">
            <option value="${changeReposUrl}"><spring:message code="repository.change"/></option>
          </c:if>
          <c:if test="${isEditableConfig}">
            <option value="${adminUrl}"><spring:message code="admin"/></option>
          </c:if>
        </select>
      </c:if>
    </td>
  </tr>
</table>
