<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:bibo="http://purl.org/ontology/bibo/"
  xmlns:dbpedia="http://dbpedia.org/resource/"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:nomisma="http://nomisma.org/id/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:schema="http://schema.org/"
  xmlns:d="http://www.paregorios.org/ns/domains"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:output method="text" encoding="UTF-8" indent="no" />
  
  <xsl:variable name="DELIMITER">,</xsl:variable>
  <xsl:variable name="TEXTSTART">"</xsl:variable>
  <xsl:variable name="TEXTEND">"</xsl:variable>
  <xsl:variable name="LINEBREAK" xml:space="preserve">
</xsl:variable>
  
  <xsl:variable name="mostsameas">
    <xsl:for-each select="//rdf:Description[rdf:type/@rdf:resource='http://dbpedia.org/resource/Roman_emperor']">
      <xsl:sort select="count(child::owl:sameAs)" data-type="number"/>
      <xsl:if test="position()=last()">
        <xsl:for-each select="child::owl:sameAs">
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="mostnames">
    <xsl:for-each select="//rdf:Description[rdf:type/@rdf:resource='http://dbpedia.org/resource/Roman_emperor']">
      <xsl:sort select="count(child::foaf:name)" data-type="number"/>
      <xsl:if test="position()=last()">
        <xsl:for-each select="child::foaf:name">
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="mostdocs">
    <xsl:for-each select="//rdf:Description[rdf:type/@rdf:resource='http://dbpedia.org/resource/Roman_emperor']">
      <xsl:sort select="count(child::foaf:isPrimaryTopicOf)" data-type="number"/>
      <xsl:if test="position()=last()">
        <xsl:for-each select="child::foaf:isPrimaryTopicOf">
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </xsl:if>        
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:template match="/">
    <!-- HEADER FOR COLUMN 1 -->
    <xsl:call-template name="emit">
      <xsl:with-param name="value">URI</xsl:with-param>
    </xsl:call-template>
    
    <!-- HEADERS FOR SAMEAS COLUMNS -->

    <xsl:message>length of mostsameas: <xsl:value-of select="count($mostsameas/owl:sameAs)"/></xsl:message>
    <xsl:for-each select="$mostsameas/owl:sameAs">
      <xsl:call-template name="emit">
        <xsl:with-param name="value">
          <xsl:text>SAMEAS</xsl:text>
          <xsl:value-of select="count(preceding::owl:sameAs)+1"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    

    <!-- HEADERS FOR COLUMNS 2 AND BEYOND (IF NEEDED): however many names we need -->

    <xsl:message>length of mostnames: <xsl:value-of select="count($mostnames/foaf:name)"/></xsl:message>
    <xsl:for-each select="$mostnames/foaf:name">
      <xsl:call-template name="emit">
        <xsl:with-param name="value">
          <xsl:text>NAME</xsl:text>
          <xsl:value-of select="count(preceding::foaf:name)+1"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    
    <!-- HEADERS FOR DOCUMENT COLUMNS -->

    <xsl:message>length of mostdocs: <xsl:value-of select="count($mostdocs/foaf:isPrimaryTopicOf)"/></xsl:message>
    <xsl:for-each select="$mostdocs/foaf:isPrimaryTopicOf">
      <xsl:call-template name="emit">
        <xsl:with-param name="value">
          <xsl:text>DOCURI</xsl:text>
          <xsl:value-of select="count(preceding::foaf:isPrimaryTopicOf)+1"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="emit">
        <xsl:with-param name="value">
          <xsl:text>DOCTITLE</xsl:text>
          <xsl:value-of select="count(preceding::foaf:isPrimaryTopicOf)+1"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    
    <!-- HEADER FOR FINAL RUNDATE COLUMN -->
    <xsl:call-template name="emit">
      <xsl:with-param name="value">RUNDATETIME</xsl:with-param>
      <xsl:with-param name="last">yes</xsl:with-param>
    </xsl:call-template>    

    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="rdf:RDF">
    <xsl:apply-templates select="rdf:Description"/>
  </xsl:template>
  
  <xsl:template match="rdf:Description[rdf:type/@rdf:resource='http://dbpedia.org/resource/Roman_emperor']">
    <!-- URI -->
    <xsl:call-template name="emit">
      <xsl:with-param name="value" select="@rdf:about"/>
    </xsl:call-template>
    
    <!-- SAMEAS -->
    <xsl:for-each select="owl:sameAs">
      <xsl:call-template name="emit">
        <xsl:with-param name="value" select="@rdf:resource"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="count(owl:sameAs) &lt; count($mostsameas/owl:sameAs)">
      <xsl:for-each select="1 to count($mostsameas/owl:sameAs) - count(owl:sameAs)">
        <xsl:call-template name="emit">
          <xsl:with-param name="type">null</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
    
    <!-- NAMES -->
    <xsl:for-each select="foaf:name">
      <xsl:call-template name="emit">
        <xsl:with-param name="value">
          <xsl:value-of select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="count(foaf:name) &lt; count($mostnames/foaf:name)">
      <xsl:for-each select="1 to count($mostnames/foaf:name) - count(foaf:name)">
        <xsl:call-template name="emit">
          <xsl:with-param name="type">null</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
    
    <!-- DOCUMENTS -->
    <xsl:for-each select="foaf:isPrimaryTopicOf">
      <xsl:call-template name="emit">
        <xsl:with-param name="value" select="@rdf:resource"/>        
      </xsl:call-template>
      <xsl:variable name="thisdoc" select="@rdf:resource"/>
      <xsl:call-template name="emit">
        <xsl:with-param name="value">
          <xsl:value-of select="//rdf:Description[@rdf:about=$thisdoc][1]/dcterms:title[1]"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="count(foaf:isPrimaryTopicOf) &lt; count($mostdocs/foaf:isPrimaryTopicOf)">
      <xsl:for-each select="1 to count($mostdocs/foaf:isPrimaryTopicOf) - count(foaf:isPrimaryTopicOf)">
        <xsl:call-template name="emit">
          <xsl:with-param name="type">null</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="emit">
          <xsl:with-param name="type">null</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
    
    
    <xsl:call-template name="emit">
      <xsl:with-param name="value" select="format-dateTime(current-dateTime(), '[Y,4]-[M,2]-[D,2]T[H,2]:[m,2]:[s,2][Z00:00t]')"/>
      <xsl:with-param name="last">yes</xsl:with-param>
    </xsl:call-template>
    
  </xsl:template>
  
  <xsl:template match="*"/>
  
  <xsl:template name="emit">
    <xsl:param name="type">text</xsl:param>
    <xsl:param name="value"/>
    <xsl:param name="last">no</xsl:param>
    
    <xsl:if test="$type='text'">
      <xsl:value-of select="$TEXTSTART"/>
    </xsl:if>
    <xsl:value-of select="$value"/>
    <xsl:if test="$type='text'">
      <xsl:value-of select="$TEXTEND"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$last='yes'">
        <xsl:value-of select="$LINEBREAK"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$DELIMITER"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>