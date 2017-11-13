<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <xsl:attribute-set name="page-sequence.loc" use-attribute-sets="page-sequence.toc">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.section.title">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.entry">
        <xsl:attribute name="margin-bottom">0.3em</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.label">
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.content">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.requested-by.label">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.requested-by.content">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.changed-by.label">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.changed-by.content">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.revision-id.label">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.revision-id.content">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.change-started.label">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.change-started.content">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.change-completed.label">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.change-completed.content">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.change-request-system.label">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.change-request-system.content">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.change-request-id.label">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.change-request-id.content">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="change-list.change-summary.label">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-list.change-summary.content">
    </xsl:attribute-set>
    
    <!-- Table -->
    <xsl:attribute-set name="change-table">
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
        <xsl:attribute name="width">100%</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="change-table.header">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-table.header.row">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-table.header.row.cell">
        <xsl:attribute name="border">0.7pt solid black</xsl:attribute>
        <xsl:attribute name="space-before">3pt</xsl:attribute>
        <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
        <xsl:attribute name="space-after">3pt</xsl:attribute>
        <xsl:attribute name="space-after.conditionality">retain</xsl:attribute>
        <xsl:attribute name="start-indent">3pt</xsl:attribute>
        <xsl:attribute name="end-indent">3pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-size">0.8em</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="change-table.body">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-table.body.row">
    </xsl:attribute-set>
    <xsl:attribute-set name="change-table.body.row.cell">
        <xsl:attribute name="border">0.7pt solid black</xsl:attribute>
        <xsl:attribute name="space-before">3pt</xsl:attribute>
        <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
        <xsl:attribute name="space-after">3pt</xsl:attribute>
        <xsl:attribute name="space-after.conditionality">retain</xsl:attribute>
        <xsl:attribute name="start-indent">3pt</xsl:attribute>
        <xsl:attribute name="end-indent">3pt</xsl:attribute>
        <xsl:attribute name="font-size">0.8em</xsl:attribute>
    </xsl:attribute-set>
    
</xsl:stylesheet>