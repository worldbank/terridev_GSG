<?xml version="1.0" encoding="UTF-8"?>
<sld:UserStyle xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:gml="http://www.opengis.net/gml">
  <sld:Name>AtlasStyler 1.9</sld:Name>
  <sld:Title/>
  <sld:FeatureTypeStyle>
    <sld:Name>UNIQUE_VALUE_POLYGON</sld:Name>
    <sld:Title>UniqueValuesPolygonRuleList</sld:Title>
    <sld:FeatureTypeName>Feature</sld:FeatureTypeName>
    <sld:Rule>
      <sld:Title>Más de 8 millones de habitantes</sld:Title>
      <ogc:Filter>
        <ogc:And>
          <ogc:PropertyIsEqualTo>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
          </ogc:PropertyIsEqualTo>
          <ogc:And>
            <ogc:Not>
              <ogc:Or>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                </ogc:PropertyIsNull>
                <ogc:PropertyIsEqualTo>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                  <ogc:Literal></ogc:Literal>
                </ogc:PropertyIsEqualTo>
              </ogc:Or>
            </ogc:Not>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
              <ogc:Literal>Más de 8 millones de habitantes</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:And>
      </ogc:Filter>
      <sld:MaxScaleDenominator>1.0E20</sld:MaxScaleDenominator>
      <sld:PolygonSymbolizer>
        <sld:Geometry>
          <ogc:PropertyName>the_geom</ogc:PropertyName>
        </sld:Geometry>
        <sld:Fill>
          <sld:CssParameter name="fill">#ad007d</sld:CssParameter>
        </sld:Fill>
        <sld:Stroke>
          <sld:CssParameter name="stroke">#6a0087</sld:CssParameter>
          <sld:CssParameter name="stroke-width">0.5</sld:CssParameter>
        </sld:Stroke>
      </sld:PolygonSymbolizer>
    </sld:Rule>
    <sld:Rule>
      <sld:Title>de 6 a 8 millones de habitantes</sld:Title>
      <ogc:Filter>
        <ogc:And>
          <ogc:PropertyIsEqualTo>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
          </ogc:PropertyIsEqualTo>
          <ogc:And>
            <ogc:Not>
              <ogc:Or>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                </ogc:PropertyIsNull>
                <ogc:PropertyIsEqualTo>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                  <ogc:Literal></ogc:Literal>
                </ogc:PropertyIsEqualTo>
              </ogc:Or>
            </ogc:Not>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
              <ogc:Literal>de 6 a 8 millones de habitantes</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:And>
      </ogc:Filter>
      <sld:MaxScaleDenominator>1.0E20</sld:MaxScaleDenominator>
      <sld:PolygonSymbolizer>
        <sld:Geometry>
          <ogc:PropertyName>the_geom</ogc:PropertyName>
        </sld:Geometry>
        <sld:Fill>
          <sld:CssParameter name="fill">#cd6666</sld:CssParameter>
        </sld:Fill>
        <sld:Stroke>
          <sld:CssParameter name="stroke">#a80000</sld:CssParameter>
          <sld:CssParameter name="stroke-width">0.5</sld:CssParameter>
        </sld:Stroke>
      </sld:PolygonSymbolizer>
    </sld:Rule>
    <sld:Rule>
      <sld:Title>de 4 a 6 millones de habitantes</sld:Title>
      <ogc:Filter>
        <ogc:And>
          <ogc:PropertyIsEqualTo>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
          </ogc:PropertyIsEqualTo>
          <ogc:And>
            <ogc:Not>
              <ogc:Or>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                </ogc:PropertyIsNull>
                <ogc:PropertyIsEqualTo>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                  <ogc:Literal></ogc:Literal>
                </ogc:PropertyIsEqualTo>
              </ogc:Or>
            </ogc:Not>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
              <ogc:Literal>de 4 a 6 millones de habitantes</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:And>
      </ogc:Filter>
      <sld:MaxScaleDenominator>1.0E20</sld:MaxScaleDenominator>
      <sld:PolygonSymbolizer>
        <sld:Geometry>
          <ogc:PropertyName>the_geom</ogc:PropertyName>
        </sld:Geometry>
        <sld:Fill>
          <sld:CssParameter name="fill">#dbb56e</sld:CssParameter>
        </sld:Fill>
        <sld:Stroke>
          <sld:CssParameter name="stroke">#a87000</sld:CssParameter>
          <sld:CssParameter name="stroke-width">0.5</sld:CssParameter>
        </sld:Stroke>
      </sld:PolygonSymbolizer>
    </sld:Rule>
    <sld:Rule>
      <sld:Title>de 2 a 4 millones de habitantes</sld:Title>
      <ogc:Filter>
        <ogc:And>
          <ogc:PropertyIsEqualTo>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
          </ogc:PropertyIsEqualTo>
          <ogc:And>
            <ogc:Not>
              <ogc:Or>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                </ogc:PropertyIsNull>
                <ogc:PropertyIsEqualTo>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                  <ogc:Literal></ogc:Literal>
                </ogc:PropertyIsEqualTo>
              </ogc:Or>
            </ogc:Not>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
              <ogc:Literal>de 2 a 4 millones de habitantes</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:And>
      </ogc:Filter>
      <sld:MaxScaleDenominator>1.0E20</sld:MaxScaleDenominator>
      <sld:PolygonSymbolizer>
        <sld:Geometry>
          <ogc:PropertyName>the_geom</ogc:PropertyName>
        </sld:Geometry>
        <sld:Fill>
          <sld:CssParameter name="fill">#f5f598</sld:CssParameter>
        </sld:Fill>
        <sld:Stroke>
          <sld:CssParameter name="stroke">#728944</sld:CssParameter>
          <sld:CssParameter name="stroke-width">0.5</sld:CssParameter>
        </sld:Stroke>
      </sld:PolygonSymbolizer>
    </sld:Rule>
    <sld:Rule>
      <sld:Title>Menos de 2 millones de habitantes</sld:Title>
      <ogc:Filter>
        <ogc:And>
          <ogc:PropertyIsEqualTo>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
            <ogc:Literal>ALL_LABEL_CLASSES_ENABLED</ogc:Literal>
          </ogc:PropertyIsEqualTo>
          <ogc:And>
            <ogc:Not>
              <ogc:Or>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                </ogc:PropertyIsNull>
                <ogc:PropertyIsEqualTo>
                  <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
                  <ogc:Literal></ogc:Literal>
                </ogc:PropertyIsEqualTo>
              </ogc:Or>
            </ogc:Not>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>rep_pobtot</ogc:PropertyName>
              <ogc:Literal>Menos de 2 millones de habitantes</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:And>
        </ogc:And>
      </ogc:Filter>
      <sld:MaxScaleDenominator>1.0E20</sld:MaxScaleDenominator>
      <sld:PolygonSymbolizer>
        <sld:Geometry>
          <ogc:PropertyName>the_geom</ogc:PropertyName>
        </sld:Geometry>
        <sld:Fill>
          <sld:CssParameter name="fill">#cdf57a</sld:CssParameter>
        </sld:Fill>
        <sld:Stroke>
          <sld:CssParameter name="stroke">#728944</sld:CssParameter>
          <sld:CssParameter name="stroke-width">0.5</sld:CssParameter>
        </sld:Stroke>
      </sld:PolygonSymbolizer>
    </sld:Rule>
  </sld:FeatureTypeStyle>
</sld:UserStyle>