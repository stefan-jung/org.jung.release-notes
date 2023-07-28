<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    exclude-result-prefixes="xs ot-placeholder">
    
    <xsl:template match="*[contains(@class,' bookmap/booklist ') and @type='change-historylist']" mode="generatePageSequences">
        <xsl:for-each select="key('topic-id', @id)">
            <xsl:choose>
                <xsl:when test="self::ot-placeholder:changelist">
                    <xsl:call-template name="createChangeList"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="processTopicSimple"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>