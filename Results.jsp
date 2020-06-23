<%@ page contentType="text/html" import="java.util.*,beans.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ page contentType="text/html" import="beans.*,java.io.*,java.sql.*, javax.sql.*,java.util.*, java.util.*, org.postgresql.*" %>

<%-- 
       Author: Brian Campbell

       This page validates input, connects to the DB, executes 
       a query and displays the results.

--%>

<!-- HTML 4.01 Strict -->
<!DOCTYPE HTML PUBLIC "-//W3C/DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<html>

  <head>
    <title>Query Results</title>
  </head>
  <body>

<%

  HttpSession sess = request.getSession(true);

  String[] inDate;
  String sLo = request.getParameter("sLo"),
	sHi = request.getParameter("sHi"),
	cLo = request.getParameter("cLo"),
	cHi = request.getParameter("cHi"),
	dLo = request.getParameter("dLo"),
	dHi = request.getParameter("dHi");
  boolean errS = false,
        errC = false,
        errD = false;
  int yearL = -1, 
        monthL = -1,
        dayL = -1,
        yearH = -1, 
        monthH = -1, 
        dayH = -1;
  
  // validate senator names
  if (sLo != null){
     if (!sLo.trim().isEmpty()){
        if (!sLo.matches("[a-zA-z]*")){
	   errS = true;
%>	   
	   (sLo) Low limit of the senator name range has non-letter characters.<br/>
<%
        }
     } else {
	   errS = true;
%>	   
	   (sLo) Low limit of the senator name range is empty.<br/>
<%
     }
  } else {
	   errS = true;
%>	   
	   (sLo) Low limit of the senator name range is missing.<br/>
<%
  }

  if (sHi != null){
     if (!sHi.trim().isEmpty()){
        if (!sHi.matches("[a-zA-Z]*")){
	   errS = true;
%>	   
	   (sHi) High limit of the senator name range has non-letter characters.<br/>
<%
        }
     } else {
	   errS = true;
%>	   
	   (sHi) High limit of the senator name range is empty.<br/>
<%
     }
  } else {
	   errS = true;
%>	   
	   (sHi) High limit of the senator name range is missing.<br/>
<%
  }
  
  if (errS == false && sLo.compareTo(sHi) > 0){
     errS = true;
     sLo = null;
     sHi = null;
  }

  // validate corporation names
   if (cLo != null){
     if (!cLo.matches("[a-zA-Z]([a-zA-Z ]*[a-zA-Z])?")){
	errC = true;
%>	   
	(cLo) Low limit of the corporation name range wrong format.<br/>
<%
     }
  } else {
	errC = true;
%>	   
	(cLo) Low limit of the corporation name range is missing.<br/>
<%
  }

  if (cHi != null){
     if (!cHi.matches("[a-zA-Z]([a-zA-Z ]*[a-zA-Z])?")){
	errC = true;
%>	   
	(cHi) High limit of the corporation name range wrong format.<br/>
<%
     }
  } else {
     errC = true;
%>	   
     (cHi) High limit of the corporation name range is missing.<br/>
<%
  }
  
  if (errC == true || cLo.compareTo(cHi) > 0){
     errC = true;
     sLo = null;
     sHi = null;
  }

  // validate dates
  if (dLo != null && !dLo.trim().isEmpty()){
     if (dLo.matches("\\d\\d\\d\\d-[\\d]?\\d-[\\d]?\\d")){
        inDate = dLo.split("-");
	yearL = Integer.parseInt(inDate[0]);
        monthL = Integer.parseInt(inDate[1]);
        dayL = Integer.parseInt(inDate[2]);

        if (yearL > 0 && monthL >= 1 && monthL <= 12 && dayL > 0){
           if (monthL == 4 || monthL == 6 || monthL == 9 || monthL == 11){
 	      if (dayL > 30)
	         errD = true;
           } else if (monthL == 2) {
	      if (yearL % 4 == 0){
	         if (dayL > 29)
                   errD = true;
              } else {
                 if (dayL > 28)
		    errD = true;
              }
           } else {
              if (dayL > 31){
		 errD = true;
              }
           }
        } else {
           errD = true;
        }

        if (errD == true){
%>
	   (dLo) Low limit of the date range is not a valid date.<br/>
<%
        }
     } else {
        errD = true;
%>
        (dLo) Low limit of the date range is of the wrong format.<br/>
<% 
     }
  } else {
     errD = true;
%>
     (dLo) Low limit of the date range is missing.<br/>
<%
  }


  if (dHi != null && !dHi.trim().isEmpty()){
     if (dHi.matches("\\d\\d\\d\\d-[\\d]?\\d-[\\d]?\\d")){
        inDate = dHi.split("-");
	yearH = Integer.parseInt(inDate[0]);
        monthH = Integer.parseInt(inDate[1]);
        dayH = Integer.parseInt(inDate[2]);

        if (yearH > 0 && monthH >= 1 && monthH <= 12 && dayH > 0){
           if (monthH == 4 || monthH == 6 || monthH == 9 || monthH == 11){
 	      if (dayH > 30)
	         errD = true;
           } else if (monthH == 2) {
	      if (yearH % 4 == 0){
	         if (dayH > 29)
                   errD = true;
              } else {
                 if (dayH > 28)
		    errD = true;
              }
           } else {
              if (dayH > 31){
		 errD = true;
              }
           }
        } else {
           errD = true;
        }

        if (errD == true){
%>
	   (dHi) High limit of the date range is not a valid date.<br/>
<%
        }
     } else {
        errD = true;
%>
        (dHi) High limit of the date range is of the wrong format.<br/>
<% 
     }
  } else {
     errD = true;
%>
     (dHi) High limit of the date range is missing.<br/>
<%
  }

  if (errD == false && (yearL > yearH || (yearL == yearH && 
     (monthL > monthH || (monthL == monthH && dayL > dayH))))){
        errD = true;
        dLo = null;
        dHi = null;
  }
     
  if (errS == false || errC == false || errD == false){
    // create a database connection;
    // better to do this through the application's configuration file

    String dbURL = "jdbc:postgresql://moth.cs.usm.maine.edu/senators?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory";
    String jdbcDriver = "org.postgresql.Driver";
    String username = "bcampbell";
    String passwd = "finish457";

    // attempt to get the saved connection
    Object savedConnection = sess.getAttribute("conn");
    Connection conn = null;
    if (savedConnection != null)
       conn = (Connection) savedConnection;
    Statement stmnt = null;
    ResultSet rs = null;
   
    try {

       // create a database connection;
       // better to do this through the application's configuration file


       // only create the connection if we do not already have one
       if (conn == null){
          Class.forName(jdbcDriver);
          conn = DriverManager.getConnection(dbURL, username, passwd);
          sess.setAttribute("conn", conn);
       }

       PreparedStatement qry = conn.prepareStatement(
           "select distinct x.cname, y.sname, " + 
               "coalesce((select count(*) " +
                        "from contributes z " +
                        "where z.cname = x.cname and z.sname = y.sname), 0) as contribCount, " +
               "coalesce((select sum(amt) " +
                        "from contributes zz " +
                        "where zz.cname = x.cname and zz.sname = y.sname), 0) as contribSum " +
           "from contributes x cross join senators y " +
           "where y.sname between ? and ? and " +
               "x.cname between ? and ? and " +
               "x.cdate >= ? and x.cdate <= ? " +
           "group by x.cname, y.sname " +
           "order by x.cname, y.sname ");

       qry.setString(1, sLo);
       qry.setString(2, sHi);
       qry.setString(3, cLo);
       qry.setString(4, cHi);
       qry.setDate(5, java.sql.Date.valueOf(dLo));
       qry.setDate(6, java.sql.Date.valueOf(dHi));
       rs = qry.executeQuery();
%>
        <table>
           <tr> <th>Corporation</th> <th>Senator</th> <th>contribCount</th> 
                <th>contribSum</th> </tr></tr/>

<%
       if (rs == null) {
          out.println("No result set for sLo = " + sLo + 
		"<br/>   sHi = " + sHi + 
		"<br/>   cLo = " + cLo + 
		"<br/>   cHi = " + cHi + 
		"<br/>   dLo = " + dLo + 
		"<br/>   dHi = " + dHi + "<br/>");
       }else{
          while (rs.next()){ 

           String corp = rs.getString(1);
           String sen = rs.getString(2);
   
           if (corp.length() > 25)
              corp = corp.substring(0, 24);
           if (corp.length() > 25)
              corp = corp.substring(0, 24);
%>
           <tr><td align="right"> <%= corp %></td>
               <td align="right"> <%= sen %></td>
               <td align="right"> <%= rs.getInt(3) %></td>
               <td align="right"> <%= rs.getInt(4) %></td></tr>
<%
          }
       }
       out.println("</table><br clear=\"all\" />");
    } 
    catch (Exception ex) {
%>
  	  Sorry, could not connect to the database.<br/>
          <%= ex %><br/>
<%
    }
    }
%>
           <a href="started.html">Return to entry page.</a>

   </body>
</html>
