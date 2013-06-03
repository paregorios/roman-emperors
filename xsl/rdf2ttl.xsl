<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 exclude-result-prefixes="xs xd"
 version="2.0">
 
 <xsl:import href="stringvars.xsl"/>
 
 <xd:doc scope="stylesheet">
  <xd:desc>
   <xd:p><xd:b>Created on:</xd:b> Jun 2, 2013</xd:p>
   <xd:p><xd:b>Author:</xd:b> paregorios</xd:p>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
 
 <xsl:output method="text" encoding="UTF-8" indent="no"/>
 
 <xsl:variable name="foaf">http://xmlns.com/foaf/0.1/</xsl:variable>
 <xsl:variable name="bibo">http://purl.org/ontology/bibo/</xsl:variable>
 <xsl:variable name="dbpedia">http://dbpedia.org/resource/</xsl:variable>
 <xsl:variable name="owl">http://www.w3.org/2002/07/owl#</xsl:variable>
 <xsl:variable name="nomisma">http://nomisma.org/id/</xsl:variable>
 <xsl:variable name="dcterms">http://purl.org/dc/terms/</xsl:variable>
 <xsl:variable name="schema">http://schema.org/</xsl:variable>
 <xsl:variable name="dir">http://www.roman-emperors.org/</xsl:variable>
 <xsl:variable name="wikipedia">http://en.wikipedia.org/wiki/</xsl:variable>
 <xsl:variable name="flickrwrappr">http://www4.wiwiss.fu-berlin.de/flickrwrappr/photos/</xsl:variable>
 
 <xsl:template match="/">
  <xsl:apply-templates/>
 </xsl:template>
 
 <xsl:template match="rdf:RDF">
  <xsl:apply-templates/>
 </xsl:template>
 
 <xsl:template match="rdf:Description">
  <xsl:value-of select="$n"/>
  <xsl:call-template name="outnoun"/>
  <xsl:apply-templates select="rdf:type"/>
  <xsl:apply-templates select="*[not(self::rdf:type)]"/>
 </xsl:template>
 
 <xsl:template match="rdf:type">
  <xsl:choose>
   <xsl:when test="preceding-sibling::rdf:type">
    <xsl:value-of select="$cntt"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text> a </xsl:text>
   </xsl:otherwise>   
  </xsl:choose>
  <xsl:call-template name="outnoun">
   <xsl:with-param name="noun" select="@rdf:resource"/>
  </xsl:call-template>
 </xsl:template>
 
 <xsl:template match="*">
  <xsl:variable name="thisname" select="name()"/>
  
  <xsl:choose>
   <xsl:when test="preceding-sibling::*[name() = $thisname]">
    <xsl:value-of select="$cntt"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$snt"/>
    <xsl:call-template name="outnoun">
     <xsl:with-param name="noun" select="name()"/>
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
   <xsl:when test="@rdf:resource">
    <xsl:call-template name="outnoun">
     <xsl:with-param name="noun" select="@rdf:resource"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="text()">
    <xsl:call-template name="outliteral">
     <xsl:with-param name="literal" select="text()"/>
    </xsl:call-template>
   </xsl:when>
  </xsl:choose>
 </xsl:template>
 
 <xsl:template name="outnoun">
  <xsl:param name="noun" select="./@rdf:about"/>
  <xsl:message>noun is <xsl:value-of select="$noun"/></xsl:message>
  <xsl:choose>
   <xsl:when test="contains($noun, '(') or contains($noun, ')')">
    <xsl:call-template name="outnounfull">
     <xsl:with-param name="noun" select="$noun"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $bibo)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $bibo)"/>
     <xsl:with-param name="prefix">bibo</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $foaf)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $foaf)"/>
     <xsl:with-param name="prefix">foaf</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $dcterms)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $dcterms)"/>
     <xsl:with-param name="prefix">dcterms</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $dbpedia)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $dbpedia)"/>
     <xsl:with-param name="prefix">dbpedia</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $nomisma)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $nomisma)"/>
     <xsl:with-param name="prefix">nomisma</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $owl)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $owl)"/>
     <xsl:with-param name="prefix">owl</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $schema)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $schema)"/>
     <xsl:with-param name="prefix">schema</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $dir)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $dir)"/>
     <xsl:with-param name="prefix">dir</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $wikipedia)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $wikipedia)"/>
     <xsl:with-param name="prefix">wikipedia</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($noun, $flickrwrappr)">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, $flickrwrappr)"/>
     <xsl:with-param name="prefix">flickrwrappr</xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="not(starts-with($noun, 'http://')) and contains($noun, ':')">
    <xsl:call-template name="outnounbrief">
     <xsl:with-param name="noun" select="substring-after($noun, ':')"/>
     <xsl:with-param name="prefix" select="substring-before($noun, ':')"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:call-template name="outnounfull">
     <xsl:with-param name="noun" select="$noun"/>
    </xsl:call-template>
   </xsl:otherwise>
   
   
   
   
   
  </xsl:choose>
 </xsl:template>
 
 <xsl:template name="outnounfull">
  <xsl:param name="noun"/>
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="$noun"/>
  <xsl:text>&gt;</xsl:text>
 </xsl:template>
 
 <xsl:template name="outnounbrief">
  <xsl:param name="noun"/>
  <xsl:param name="prefix"/>
  <xsl:value-of select="$prefix"/>
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$noun"/>
 </xsl:template>
 
 <xsl:template name="outliteral">
  <xsl:param name="literal"/>
  <xsl:text>"</xsl:text>
  <xsl:value-of select="$literal"/>
  <xsl:text>"</xsl:text>
 </xsl:template>
</xsl:stylesheet>