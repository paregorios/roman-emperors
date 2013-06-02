<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 exclude-result-prefixes="xs xd"
 version="2.0">
 <xd:doc scope="stylesheet">
  <xd:desc>
   <xd:p><xd:b>Created on:</xd:b> Jun 2, 2013</xd:p>
   <xd:p><xd:b>Author:</xd:b> paregorios</xd:p>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
 
 <xsl:output encoding="UTF-8"  method="xml" indent="yes"/>
 
 <xsl:template match="/">
  <xsl:apply-templates/>
 </xsl:template>
 
 
 <xsl:template match="rdf:RDF">
  <xsl:copy>
   <xsl:copy-of select="@*"/>
   <xsl:for-each-group select="//rdf:Description" group-by="@rdf:about">
    <xsl:sort select="current-grouping-key()"/>
    <xsl:element name="rdf:Description">
     <xsl:attribute name="rdf:about">
      <xsl:value-of select="@rdf:about"/>
     </xsl:attribute>
     <xsl:variable name="about" select="@rdf:about"/>
    <xsl:for-each select="ancestor::rdf:RDF/rdf:Description[@rdf:about=$about]/*">
     <xsl:sort select="name()"/>
     <xsl:sort select="@rdf:resource"/>
     <xsl:sort select="."/>
     <xsl:call-template name="copythis"/>
    </xsl:for-each>
    </xsl:element>
   </xsl:for-each-group>
  </xsl:copy>
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