<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 xmlns:foaf="http://xmlns.com/foaf/0.1/"
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns:schema="http://schema.org/"
 exclude-result-prefixes="xs xd"
 version="2.0">
 <xd:doc scope="stylesheet">
  <xd:desc>
   <xd:p><xd:b>Created on:</xd:b> Jun 2, 2013</xd:p>
   <xd:p><xd:b>Author:</xd:b> paregorios</xd:p>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
 
 <xsl:variable name="schemauri">http://schema.org/</xsl:variable>
 
 <xsl:output encoding="UTF-8"  method="xml" indent="yes"  />
 
 <xsl:template match="/">
  <xsl:apply-templates/>
 </xsl:template>
 
 <xsl:template name="rdf:RDF">
  <rdf:RDF xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
   xmlns:foaf="http://xmlns.com/foaf/0.1/"
   xmlns:bibo="http://purl.org/ontology/bibo/"
   xmlns:dbpedia="http://dbpedia.org/resource/"
   xmlns:owl="http://www.w3.org/2002/07/owl#"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:nomisma="http://nomisma.org/id/"
   xmlns:dcterms="http://purl.org/dc/terms/"
   xmlns:schema="http://schema.org/">
   <xsl:copy-of select="@*"/>
   <xsl:apply-templates/>
  </rdf:RDF>>
 </xsl:template>
 
 <xsl:template match="rdf:Description">
  <xsl:copy>
   <xsl:copy-of select="@*"/>
   <xsl:apply-templates/>
   <xsl:variable name="about" select="@rdf:about"/>
   <xsl:message>seeking <xsl:value-of select="$about"/></xsl:message>
   <xsl:for-each select="//rdf:Description[foaf:isPrimaryTopicOf/@rdf:resource=$about]">
    <xsl:element name="schema:about">
     <xsl:attribute name="rdf:resource">
      <xsl:value-of select="@rdf:about"/>
     </xsl:attribute>
    </xsl:element>
   </xsl:for-each>
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="rdf:type[@rdf:resource='http://xmlns.com/foaf/0.1/Person']">
  <xsl:call-template name="copythis"/>
  <xsl:element name="rdf:type">
   <xsl:attribute name="rdf:resource">
    <xsl:value-of select="$schemauri"/>
    <xsl:text>Person</xsl:text>
   </xsl:attribute>
  </xsl:element>
 </xsl:template>
 
 
 <xsl:template match="rdf:type[@rdf:resource='http://xmlns.com/foaf/0.1/page']">
  <xsl:call-template name="copythis"/>
  <xsl:element name="rdf:type">
   <xsl:attribute name="rdf:resource">
    <xsl:value-of select="$schemauri"/>
    <xsl:variable name="about" select="ancestor::rdf:Description/@rdf:about"/>
    <xsl:choose>
     <xsl:when test="contains($about, 'roman-emperors.org') and contains($about, '.htm')">
      <xsl:text>ScholarlyArticle</xsl:text>
     </xsl:when>
     <xsl:when test="contains($about, 'flickrwrappr/photos/')">
      <xsl:text>ImageGallery</xsl:text>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>WebPage</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>
  </xsl:element>
 </xsl:template>
 
 
 <xsl:template match="*">
  <xsl:call-template name="copythis"/>
 </xsl:template>
 
 <xsl:template name="copythis">
  <xsl:copy>
   <xsl:copy-of select="./@*"/>
   <xsl:apply-templates/>
  </xsl:copy>
 </xsl:template>
</xsl:stylesheet>