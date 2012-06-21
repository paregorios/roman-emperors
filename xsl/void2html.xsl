<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:void="http://rdfs.org/ns/void#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs void rdf dcterms foaf"
    version="2.0">
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
        <html>
            <xsl:apply-templates/>
        </html>
    </xsl:template>
    
    <xsl:template match="rdf:RDF">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="void:DatasetDescription">
        <head>
            <title><xsl:value-of select="normalize-space(dcterms:title)"/></title>
        </head>
        <body>
            <h1><xsl:value-of select="normalize-space(dcterms:title)"/></h1>
            <p>This document describes <xsl:value-of select="count(foaf:primaryTopic/void:Dataset)"/><xsl:text> dataset</xsl:text>
                <xsl:choose>
                    <xsl:when test="count(foaf:primaryTopic/void:Dataset) = 1"/>
                    <xsl:otherwise><xsl:text>s</xsl:text></xsl:otherwise>
                </xsl:choose>
                <xsl:text>.</xsl:text>
            </p>
            <xsl:apply-templates select="foaf:primaryTopic/void:Dataset"/>
        </body>
    </xsl:template>
    
    <xsl:template match="void:Dataset">
        <div class="dataset">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="dcterms:title">
        <h2><xsl:value-of select="normalize-space(.)"/></h2>
    </xsl:template>
    
    <xsl:template match="void:feature[not(preceding-sibling::void:feature)]">
        <h3>the following features are provided:</h3>
        <ul><xsl:for-each select="../void:feature">
            <li><a href="{@rdf:resource}">
            <xsl:choose>
                <xsl:when test="@rdf:resource='http://www.w3.org/ns/formats/Turtle'">Turtle</xsl:when>
                <xsl:when test="@rdf:resource='http://www.w3.org/ns/formats/RDF_XML'">RDF XML</xsl:when>
                <xsl:otherwise><xsl:value-of select="@rdf:resource"/></xsl:otherwise>
            </xsl:choose>
            </a></li>
        </xsl:for-each></ul>
    </xsl:template>
    
    <xsl:template match="void:feature"/>
    
    <xsl:template match="void:vocabulary[not(preceding-sibling::void:vocabulary)]">
        <h3>the following vocabularies are used in this dataset:</h3>
        <ul><xsl:for-each select="../void:feature">
            <li><a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a></li>
        </xsl:for-each></ul>
    </xsl:template>
    
    <xsl:template match="void:vocabulary"/>
    
    <xsl:template match="void:dataDump[not(preceding-sibling::void:dataDump)]">
        <h3>the following data dumps are provided:</h3>
        <ul><xsl:for-each select="../void:feature">
            <li>
                <xsl:choose>
                    <xsl:when test="ends-with(@rdf:resource,'.ttl')">Turtle: </xsl:when>
                    <xsl:when test="ends-with(@rdf:resource, 'rdf')">RDF XML: </xsl:when>
                </xsl:choose>
                <a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a></li>
        </xsl:for-each></ul>
    </xsl:template>
    
    <xsl:template match="void:dataDump"/>
    
    <xsl:template match="dcterms:* | foaf:homepage[not(ancestor::foaf:Person)] | void:*">
        <p>
            <xsl:text></xsl:text><strong><xsl:value-of select="local-name()"/>:</strong><xsl:text> </xsl:text>
        
        <xsl:choose>
            <xsl:when test="@rdf:resource">
                <xsl:variable name="target" select="@rdf:resource"/>
                <xsl:choose>
                    <xsl:when test="//*[@rdf:about=$target]">
                        <xsl:apply-templates select="//*[@rdf:about=$target]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text></xsl:text><a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a><xsl:text></xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="child::*">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
        </xsl:choose>
        </p>
    </xsl:template>
    
    <xsl:template match="foaf:Person">
        <span class="person">
            <xsl:text></xsl:text><xsl:value-of select="foaf:name"/><xsl:text></xsl:text>
            <xsl:if test="foaf:*[local-name() != 'name']">
                <xsl:text> (</xsl:text><xsl:apply-templates select="foaf:*[local-name() != 'name']"/><xsl:text>)</xsl:text>
            </xsl:if>
        </span>
    </xsl:template>
    
    <xsl:template match="foaf:homepage[ancestor::foaf:Person]">
        <xsl:text>homepage: </xsl:text><a href="{@rdf:resource}"><xsl:value-of select="@rdf:resource"/></a><xsl:if test="following-sibling::foaf:*"><xsl:text>, </xsl:text></xsl:if>
    </xsl:template>
    
    
    
    <xsl:template match="*"/>
        
</xsl:stylesheet>