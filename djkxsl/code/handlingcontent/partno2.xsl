<?xml version="1.0" encoding="utf-8"?>
<!--
 ! Excerpted from "XSL Jumpstarter",
 ! published by The Pragmatic Bookshelf.
 ! Copyrights apply to this code. It may not be used to create training material, 
 ! courses, books, articles, and the like. Contact us if you are in doubt.
 ! We make no guarantees that this code is fit for any purpose. 
 ! Visit http://www.pragmaticprogrammer.com/titles/djkxsl for more book information.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="parts">
  <parts>
    <xsl:apply-imports/>
  </parts>
</xsl:template>

<xsl:template match="partno"> 
  <xsl:element name="{@prefix}"> 
   <xsl:value-of select="."/> 
  </xsl:element> 
</xsl:template>
  
</xsl:stylesheet>