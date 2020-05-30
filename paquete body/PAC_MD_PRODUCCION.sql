CREATE OR REPLACE PACKAGE BODY TALLER38.pac_md_produccion
AS
   /*************************************************************************************************

    NOMBRE:      PAC_MD_PRODUCCION
    PROPÓSITO:   Funciones para la producción en segunda capa

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        27/12/2007   JAS               1. Creación del package.
    2.0        04/03/2009   DRA               2. 0009296: IAX - Implementar el circuit de recobrament de rebuts en l'emissió de pólisses pendents d'emetre
    3.0        12/02/2009   RSC               3. Preguntas semiautomáticas
    4.0        27/02/2009   RSC               4. Adaptación iAxis a productos colectivos con certificados
    5.0        11/03/2009   RSC               5. Análisis adaptación productos indexados
    6.0        01/04/2009   SBG               6. S'afegeix parÃ metre p_filtroprod a funció f_consultapoliza
    7.0        30/03/2009   DRA               7. 0009640: IAX - Modificar missatge de retenció de pólisses pendents de facultatiu
    8.0        23/04/2009   DRA               8. 0009718: IAX - clausulas especiales por producto
    9.0        28/04/2009   APD               9. 0009720: APR - fnumero de poliza incorrecto en NP
    10.0       07/05/2009   DRA              10. 0009981: IAX - Baixar l'empresa a totes les taules del model CFG
    11.0       19/05/2009   APD              11. 0010127: IAX- Consultas de pólizas, simulaciones, reembolsos y póliza reteneidas
    11.1       21/05/2009   APD              11.1 BUG10178: IAX - Vista AGENTES_AGENTE por empresa
    11.2       26/05/2009   APD              11.2 Bug 9390: se añade la condicion nmovimi desc en el ORDER BY
                                                  en la funcion f_get_mvtpoliza
    11.3       04/06/2009   DCT              11.3.Bug 10090: Modificación de pólizas de otros usuarios
    12.0       09/06/2009   DRA              12.0 0009329: IAX - Error gestió sobreprimes en pólisses GUARDADES en l'emissió.
    13.0       15/06/2009   JTS              13.0 BUG 10069
    14.0       26/06/2009   ETM              14. BUG 0010549: CIV - ESTRUC - Fecha de efecto fija para un producto
    15.0       14/07/2009   DRA              15.0 0008947: CRE046 - Gestión de cobertura Enfermedad Grave en siniestros
    16.0       13-08-2009:  XPL              16. 0010093, se añade el cramo, consulta polizas
    17.0       20/07/2009   JRH              17. Bug-10336 : CRE - Simular producto de rentas a partir del importe de renta y no de la prima
    18.0       01-09-2009:  XPL              18. 11008, CRE - Afegir camps de cerca en la pantalla de selecció de certificat 0.
    19.0       01/10/2009   JRB              19. BUG0011196: Gestión de propuestas retenidas
    20.0       23/09/2009   DRA              20. 0011183: CRE - Suplemento de alta de asegurado ya existente
    21.0       15/12/2009   JTS/NMM          21. 10831: CRE - Estado de pólizas vigentes con fecha de efecto futura
    22.0       18/01/2010   DRA              22. 0012215: CRE - SUPLEMENTS: El suplement d'alta de risc no calcula les preguntes semi-automÃ tiques
    23.0       19/01/2010   RSC              23. 0011735: APR - suplemento de modificación de capital /prima
    24.0       28/01/2010   DRA              24. 0010464: CRE - L'anul lació de propostes pendents d'emetre no tira enderrera correctament el moviment anul lat.
    25.0       24/03/2010   JRH              25. 0012136: CEM - RVI - Verificación productos RVI
    26.0       29/03/2010   JRH              26. 0013969: CEM301 - RVI - Ajustes formulación provisiones
    27.0       27/04/2010   JRH              27. 0014285: CEM-Se añade interes y fppren
    28.0       11/05/2010   RSC              28. 0011735: APR - suplemento de modificación de capital /prima
    29.0       12/05/2010   AMC              29. Bug 14443 - Se añade la función f_get_domicili_prenedor
    30.0       26/05/2010   DRA              30. 0011288: CRE - Modificación de propuestas retenidas
    31.0       01/06/2010   DRA              31. 0014754: CRE800- Edición propuesta suplemento póliza 2005407
    32.0       10/06/2010   RSC              32. 0013832: APRS015 - suplemento de aportaciones únicas
    33.0       09/08/2010   AVT              33. 15638: CRE998 - Multiregistre cercador de pólisses (Asegurat)
    34.0       23/08/2010   DRA              34. 0015617: AGA103 - migración de pólizas - Numeración de polizas
    35.0       19/10/2010   DRA              35. 0016372: CRE800 - Suplements
    36.0       20/10/2010   JRH              36. BUG 0016217: Mostrar cuadro de capitales para la pólizas de rentas
    37.0       05/08/2010   VCL              37. 15468: GRC - Búsqueda de pólizas. Añadir NÂ° Solicitud
    38.0       05/11/2010   APD              38. 16095: Implementacion y parametrizacion producto GROUPLIFE
    39.0       21/05/2010   ICV              39. 14586: CRT - Añadir campo recibo compañia
    40.0       22/11/2010   APD              40. 16768: APR - Implementación y parametrización del producto GROUPLIFE (II)
    41.0       27/12/2010   JMP              41. 0017008: GRC - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nÂ° de póliza
    42.0       28/01/2011   JTS              42. 0017459: AGA800 - consulta de pólisses no funciona amb cerques per nom de domicili
    43.0       24/01/2011   JMP              43. 0017341: APR703 - Suplemento de preguntas - FlexiLife
    44.0       02/02/2011   RSC              44. 0017341: APR703 - Suplemento de preguntas - FlexiLife
    45.0       23/03/2011   SRA              45. 0017922: AGM003 - Consulta pólizas. Modificación de las fuciones de DDBB para que incluyan las pólizas externas.
    46.0       14/04/2011   DRA              46. 0018024: CRT - Parametrizar comision de seguro
    47.0       19/04/2011   APD              47. 0018085: AGA601 - Modificaciones RC escolar
    48.0       26/04/2011   JMC              48. 0016730: CRT902 - Aplicar visibilidad oficina en consultas masivas
    49.0       28/04/2011   ICV              49. 0017950: CRT003 - Alta rapida poliza correduria (simplificar campos)
    50.0       06/05/2011   ICV              50. 0016730: CRT902 - Aplicar visibilidad oficina en consultas masivas
    51.0       16/05/2011   JMC              51. 0018561: AGM703 - Incidencia en la carga del fichero de pólizas.
    58.0       15/07/2011   JTS              58. 0018926: MSGV003- Activar el suplement de canvi de forma de pagament
    59.0       30/08/2011   JMF              59. 0019332: LCOL001 -numeración de pólizas y de solicitudes
    60.0       01/09/2011   DRA              60. 0018682: AGM102 - Producto SobrePrecio- Definicin y Parametrizacin
    61.0       06/10/2011   JMC              61. 0019110: AGM701 - El filtro de la consulta de pólizas no tiene en cuenta ramo ni agente
    62.0       27/09/2011   DRA              62. 0019069: LCOL_C001 - Co-corretaje
    63.0       21/11/2011   APD              63. 0018946: LCOL_P001 - PER - Visibilidad en personas
    64.0       02/01/2012   AVT              64. 0019484: LCOL_T001: Retención por facultativo antes de emitir la propuesta (más d'un quadre)
    65.0       10/01/2012   JMF              65. 0019931: LCOL_S001-SIN - No mostrar propuestas de pól. en el alta de siniestros
    66.0       13/01/2012   APD              66. 0020683: LCOL - UAT - PER - Revisar la check por defecto en nueva producción de cuentas bancarias.
    67.0       19/01/2012   RSC              67. 0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos
    68.0       03/01/2012   JMF              68. 0020761 LCOL_A001- Quotes targetes
    69.0       31/01/2012   AVT              69. 0021051 A0021051: LCOL_T001-LCOL - UAT - TEC - Incidencias Reaseguro: Taules reals al f_crear_facul
    70.0       09/01/2012   DRA              70. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
    71.0       01/03/2012   DRA              71. 0021467: AGM- Quitar en la descripción de riesgos el plan y al final se muestran caracteres raros
    72.0       20/03/2012   DRA              72. 0021710: MDP - Documentación requerida
    73.0       20/04/2012   APD              73. 0021786: MDP_T001-Modificaciones pk_nueva_produccion para corregir inidencias en dependencias
    74.0       11/05/2012   DRA              74. 0021927: MDP - TEC - Parametrización producto de Hogar (MHG) - Nueva producción
    75.0       23/04/2011   MDS              75. 0021907: MDP - TEC - Descuentos y recargos (tácnico y comercial) a nivel de póliza/riesgo/garantÃ­a
    76.0       20/06/2012   MDS              76. 0021924: MDP - TEC - Nuevos campos en pantalla de Gestión (Tipo de retribución, Domiciliar 1Â° recibo, Revalorización franquicia)
    77.0       18/07/2012   MDS              77. 0022824: LCOL_T010-Duplicado de propuestas
    78.0       31/07/2012   FPG              78. 0023075: LCOL_T010-Figura del pagador
    79.0       01/10/2012   DRA              79. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
    80.0       25/10/2012   DRA              80. 0023853: LCOL - PRIMAS MÃ¿?NIMAS PACTADAS POR PÓLIZA Y POR COBRO
    81.0       30/10/2012   MDS              81. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
    82.0       13/11/2012   XVM              82. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
    83.0       15/11/2012   APD              83. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovacion colectivos
    84.0       22/11/2012   MDS              84. 0024657: MDP_T001-Pruebas de Suplementos
    85.0       05/12/2012   APD              85. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
    86.0       24/12/2012   AMJ              86. 0024722: (POSDE600)-Desarrollo-GAPS Tecnico-Id 176 - Numero de Anexo en Impresion
    87.0       11/01/2013   APD              86. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovacion colectivos
    88.0       18/01/2013   JDS              87. 0025503: LCOL_T020-Qtracker: 0005656: Error en cuadros facultativos
    89.0       20/12/2012   MDS              89. 0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
    90.0       07/02/2013   JDS              90. 0025583: LCOL - Revision incidencias qtracker (IV)
    91.0       16/02/2013   DRA              91. 0026111: LCOL: Revisar Retorno en Colectivos
    92.0       21/02/2013   ECP              92. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V). Nota 138777
    93.0       28/02/2013   ECP              93. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V). Nota  139391
    94.0       04/03/2013   APD              94. 0026151: LCOL - QT 6096 - Anular movimientos de carátula
    95.0       04/03/2013   JDS              95. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V)
    96.0       07/03/2013   APD              96. 0026151: LCOL - QT 6096 - Anular movimientos de carátula
    97.0       11/03/2013   AEG              97. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
   98.0        12/03/2013   JMF              0026341: LCOL: Comisiones de recibos
   99.0        19/03/2013   ECP              99. 0026488: LCOL_T010-LCOL - Revision incidencias qtracker (VI)
   100.0       12/04/2013   MMS             100.  0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza Â‘Â˜hasta edadÂ’ y edades permitidas por producto - add NEDAMAR
   101.0       21/05/2013   ECP             101. 0026488: LCOL_T010-LCOL - Revision incidencias qtracker (VI) /143970
   102.0       04/06/2013   DCT             102. 0027081: LCOL_PROD-QT 6947: Consulta de Vetos IAXIS LIBELULA
   103.0       21/06/2013   DCT             103. 0026488: LCOL_T010-LCOL - Revision incidencias qtracker (VI)
   104.0       25/06/2013   RCL             104  0024697: Canvi mida camp sseguro
   105.0       24/07/2013   DCT             105. 0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
   106.0       06/09/2013   DCT             106. 0027923  LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado
   107.0       14/10/2013   JSV             106. 0027923: LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0
   108.0       18/10/2013   JSV             107. 0027048: LCOL_T010-Revision incidencias qtracker (V)
   109.0       22/10/2013   JSV             108. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
   110.0       22/10/2013   DCT             110 .0027923: LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0
   111.0       28/10/2013   RCL             111. 0028479: LCOL895-Incidencias Fase 2 Post-Producci?n UAT
   112.0       18/11/2013   FPG             112. 0028263: LCOL899-Proceso EmisiÓn Vida Grupo - Desarrollo modificaciones de iAxis para BPM
   113.0       22/11/2013   RCL             113. 0027048: LCOL_T010-Revision incidencias qtracker (V)
   114.0       28/11/2013   RCL             114. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
   115.0       12/12/2013   RCL             115. 0027048: LCOL_T010-Revision incidencias qtracker (V) - Emision masiva (polizas agrupadas)
   116.0       17/12/2013   RCL             116. 0029358: LCOL_T010-LCOL - Revision incidencias qtracker (VIII)
   117.0       19/12/2013   RCL             117. 0027048: LCOL_T010-Revision incidencias qtracker (V)
   118.0       21/01/2014   JDS             118.0029603: POSRA300-Texto en la columna Pagador del Recibo para recibos de Colectivos
   119.0       24/01/2014   SCO             119.0027417: POSRA300 - Control errores query revalorización en F_Get_Reval_Poliza
   120.0       15/04/2014   dlF             113. 0030779: Problemas al emitir pólizas autorizadas previamente
   121.0       30/04/2014   FAL             114. 0027642: RSA102 - Producto Tradicional
   122.0       15/04/2015   FAL             115. 0035409: T - Producto Convenios
   123.0       13/05/2015   KJSC            123. 33116-189842 Cambiar missatge d'error per informatiu en la generació dels Quadres Facutatius
   124.0       01/07/2015   IGIL            0035888/203837 quitar UPPER a NNUMNIF
   125.0       18/08/2015   YDA             125. 0034627: Se modifica f_consultapoliza para consultar pólizas validas cuando es pignoración
   126.0       02/10/2015   KJSC            126. 0036507: Funcion apunte retencion cuando salte una PSU
   127.0       09/12/2015   FAL             127. 0036730: I - Producto Subsidio Individual
   128.0       15/04/2015   JMT             128. 0026373: ENSA998-Envio Automatico de email para os contribuintes
   129.0       17/03/2016   JAEG            128. 41143/229973: Desarrollo Diseño tácnico CONF_TEC-01_VIGENCIA_AMPARO
   130.0       16/06/2016   VCG             130. AMA-187-Realizar el desarrollo del GAP 114
   131.0       23/01/2018   JLTS            131. BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
   132.0       08/02/2018   JLTS            132. BUG CONF-1243 QT_1354 - Iaxis no actualiza la vigencia de las coberturas dentro del mismo flujo de Alta de Poliza
   133.0       27/02/2019   ACL             TCS_827 Se agrega la funcion f_consultapoliza_contrag.
   134.0       06/03/2019   ACL             TCS_827 Se modifica la funcion f_consultapoliza_contrag con ajuste de exclusiones de bosquedas
   135.0       19/03/2019   CJMR            135. IAXIS-3194: Adicion de nuevos campo de busqueda
   136.0       22/03/2019   CJMR            136. IAXIS-3195: Adicion de nuevos campo de busqueda
   137.0       04/04/2019   CJMR            137. IAXIS-3368: Se agrega validadcion para fechas de vigencias de amparos
   138.0       05/04/2019   CES             138. IAXIS-2132: Ajuste para la creaciun de beneficiarios por defecto que sean los asegurados.
   139.0       26/04/2019   ECP             139. IAXIS-3634: Gestor Documental (Documentos internos y externos)
   140.0       22/03/2019   CJMR            140. IAXIS-3195: Adición de nuevos campo de búsqueda
   141.0       24/05/2019   ECP             141. IAXIS-3592  Proceso de terminación por no pago
   142.0       18/06/2019   ROHIT           142. IAXIS-4320:-Errores Ramo Cumplimiento ( for not showing :-¡Axis modifique también el Beneficiario, lo cual está haciendo pero está acumulando con el anterior beneficiario.)
   143.0       26/06/2019   CJMR            143. IAXIS-4203: Configuración productos RCE
   144.0       08/07/2019   ROHIT           144. IAXIS-4746: Error Endorsement change of Insured in Compliance, is not changing including / modifying the Beneficiary
   145.0       01/07/2019   FEPP            145. IAXIS-4503: Se debe validar por que al realizar modificaciÃ³n de una pÃ³liza que tiene cuadro facultativo, no recalcula el valor ni permite modificar el cuadro
   146.0       18/07/2019   ROHIT           146. IAXIS-4545 Antecedentes: Para el ramo de cumplimiento el asegurado es el mismo BENEFICIARIO, se requiere que al realizar suplemento de cambio de Asegurado ¡Axis modifique también el Beneficiario, lo cual está haciendo pero está acumulando con el anterior beneficiario
   147.0       05/08/2019   SPV             147. IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
   148.0       10/08/2019   CJMR            148. IAXIS-4205: Endosos RC: Fecha de vigencia en Alta de amparos
   149.0       22/08/2019   CJMR            149. IAXIS-5105: Modificación vigencias en Nueva producción
   150.0       04/09/2019   CJMR            150. IAXIS-5222. Fechas de vigencia en Amparo de salarios (7005) - Cumplimiento
   151.0       06/09/2019   CJMR            151. IAXIS-4203. Ajuste por duplicidad de beneficiario
   152.0       17/09/2019   CJMR            152. IAXIS-5281 Beneficiario TERCEROS AFECTADOS no debe ser eliminado en RC
   153.0       23/10/2019   DFR             153. IAXIS-4926: Anulación de póliza y movimientos con recibos abonados y Reversión de recaudos en recibos.
   154.0       20/11/2019   DFR             154. IAXIS-7650: ERROR BAJA DE AMPAROS
   155.0       18/12/2019   ECP             155. IAXIS-3504.Pantallas gestión Suplementos
   156.0       12/02/2020   CJMR            156. IAXIS-5274. Solución bug IAXIS-12902
   157.0       25/02/2020   CJMR            157. IAXIS-12903. Solución al bug
   158.0       03/03/2020   ECP             158. IAXIS-11899. Importes sección recibos en la pantalla de consulta pólizas
   159.0       27/04/2020   DFR             159. IAXIS-12992: Cesión en contratos con más de un tramo
   160.0       18/05/2020   ECP             160. IAXIS-13888. Error Gestión Agenda
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*************************************************************************
      Cambia la fecha efecto, dependiendo del producto.
      param in psseguro     : Número de seguro
      param in pnmovimi     : Número de movimiento
      param in pfefecto     : Fecha Efecto seguro
      param in pNewFEfecto  : Nueva fecha de efecto
      param in out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_cambia_f_efecto (
      psseguro      IN   seguros.sseguro%TYPE,
      pnmovimi      IN   movseguro.nmovimi%TYPE,
      pproducto     IN   seguros.sproduc%TYPE,
      pfefecto      IN   seguros.fefecto%TYPE,
      pnewfefecto   IN   seguros.fefecto%TYPE
   )
      RETURN NUMBER
   IS
      dfefecto   seguros.fefecto%TYPE   DEFAULT pnewfefecto;
      dfecha     seguros.fefecto%TYPE;
   BEGIN
      IF NVL (f_parproductos_v (pproducto, 'CAMBIA_FEFECTO_PROP'), 0) = 1
      THEN
         dfecha :=
             pnewfefecto - NVL (f_parproductos_v (pproducto, 'DIASATRAS'), 0);

         IF dfecha <= pfefecto
         THEN
            dfefecto := pfefecto;
         END IF;
      END IF;

      RETURN pac_seguros.f_set_fefecto (psseguro, dfefecto, pnmovimi);
   END;

   /*************************************************************************
      Crea los objetos necesarios
      param in out dtPoliza : objeto detalle poliza
      param in out gestion  : objeto gestión
      param in out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE inicializaobjetos (
      dtpoliza   IN OUT   ob_iax_detpoliza,
      gestion    IN OUT   ob_iax_gestion,
      mensajes   IN OUT   t_iax_mensajes
   )
   IS
      vpasexec       NUMBER (8)     := 1;
      vparam         VARCHAR2 (1)   := NULL;
      vobject        VARCHAR2 (200) := 'PAC_MD_PRODUCCION.InicializaObjetos';
      vcpctfall      NUMBER;
      vnpctfall      NUMBER;
      vnpctfallmin   NUMBER;
      vnpctfallmax   NUMBER;
   BEGIN
      /* ACC 13122008 s'ha de comprovar que no estiguen en cap mode de consulta*/
      /* ni fent un suplement, si ho esta hem de sortir*/
      /* BUG9107:DRA:19-02-2009*/
      IF    pac_iax_produccion.issuplem
         OR pac_iax_produccion.isconsult
         OR pac_iax_produccion.ismodifprop
      THEN
         RETURN;
      END IF;

      SELECT p.cobjase, p.csubpro, p.cagrpro,
             p.ctarman, p.cpagdef, p.cduraci,
             p.ctipreb, p.creccob, p.crevali,
             p.irevali, p.prevali, p.crecfra,
             p.creteni, pr.cpctrev, pr.npctrev,
             p.ndurcob /* Mantis 7919.#6.12/2008.*/, cpctfall,
             npctfall, npctfallmin, npctfallmax, p.cobjase,
             p.ccompani
        INTO dtpoliza.cobjase, dtpoliza.csubpro, dtpoliza.cagrpro,
             dtpoliza.ctarman, dtpoliza.cpagdef, gestion.cduraci,
             dtpoliza.ctipreb, dtpoliza.creccob, dtpoliza.crevali,
             dtpoliza.irevali, dtpoliza.prevali, gestion.crecfra,
             /* Mantis 7920.#6.12/2008.*/
             dtpoliza.creteni, gestion.cpctrev, gestion.npctrev,
             gestion.ndurcob_prod /* Mantis 7919.#6.12/2008.*/, vcpctfall,
             vnpctfall, vnpctfallmin, vnpctfallmax,
                                                   /*JRH 03/20010 De momento no lo ponemos en ningún objeto*/
                                                   dtpoliza.cobjase,
             dtpoliza.ccompani
        FROM productos p, producto_ren pr
       WHERE p.sproduc = dtpoliza.sproduc AND p.sproduc = pr.sproduc(+);

      IF gestion.pdoscab IS NULL
      THEN
         gestion.pdoscab := gestion.npctrev;
      /*Inicializamos pct de reversión*/
      END IF;

      /* BUG 21924 - 16/04/2012 - ETM*/
      IF gestion.cindrevfran IS NULL
      THEN
         gestion.cindrevfran :=
                   NVL (f_parproductos_v (dtpoliza.sproduc, 'REVALFRANQ'), 0);
      END IF;

      IF gestion.ctipretr IS NULL
      THEN
         BEGIN
            SELECT ctipretrib
              INTO gestion.ctipretr
              FROM agentes
             WHERE cagente = dtpoliza.cagente;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      /* fin BUG 21924 - 16/04/2012 - ETM*/
      IF gestion.pcapfall IS NULL
      THEN
         /* Bug 12136 - 24/03/2010 - JRH - 0012136: CEM - RVI - Verificación productos RVI*/
         gestion.pcapfall := 0;          /*Inicializamos pct de cap. fallec*/

         IF vcpctfall = 1
         THEN
            /*Fijo*/
            gestion.pcapfall := vnpctfall;
         ELSIF vcpctfall = 2
         THEN
            /*Variable*/
            gestion.pcapfall := vnpctfallmin;
         END IF;
      /* Fi Bug 12136 - 24/03/2010 - JRH*/
      END IF;

      vpasexec := 2;

      SELECT DECODE (dtpoliza.cpagdef, 1, 0, 1)
        INTO dtpoliza.nfracci
        FROM DUAL;

      vpasexec := 3;

      /* Si el npoliza se asigan en la emisión, se graba el número de solicitud*/
      IF NVL (f_parproductos_v (dtpoliza.sproduc, 'NPOLIZA_EN_EMISION'), 0) =
                                                                             1
      THEN
         /* BUG 0019332 - 30/08/2011 - JMF*/
         dtpoliza.nsolici :=
            pac_propio.f_numero_solici (pac_md_common.f_get_cxtempresa,
                                        dtpoliza.cramo
                                       );
      END IF;

      /* Bug 8745 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados*/
      IF pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                dtpoliza.sproduc
                                               ) = 1
      THEN
         IF NVL (f_parproductos_v (dtpoliza.sproduc, 'NPOLIZA_EN_EMISION'),
                 0) = 1
         THEN
            SELECT ssolicit_certif.NEXTVAL
              INTO dtpoliza.ncertif
              FROM DUAL;
         END IF;
      END IF;

      gestion.cmonpol := pac_parametros.f_parinstalacion_n ('MONEDAINST');

      IF gestion.cmonpol IS NOT NULL
      THEN
         gestion.tmonpol :=
            pac_md_listvalores.f_get_tmoneda (gestion.cmonpol,
                                              gestion.cmonpolint,
                                              mensajes
                                             );
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
   END inicializaobjetos;

   /*************************************************************************
      Traspasa una póliza de las tablas EST a las tablas REALES
      param in psseguro   : Número de seguro
      param out           : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_traspasarpoliza (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr             NUMBER (8)                      := 0;
      vsproduc            NUMBER;
      vcramo              NUMBER;
      vfefecto            DATE;
      vssegpol            NUMBER;
      vnsolici            NUMBER;
      vmens               VARCHAR2 (1000);
      vmode               VARCHAR2 (20);
      vprimatotal         NUMBER;
      fsuplem             DATE;
      num_err             NUMBER                          := 0;
      /*cmotmov        NUMBER; -- BUG 0035409 - FAL - 15/04/2015*/
      wcmotmov            NUMBER;         /* BUG 0035409 - FAL - 15/04/2015*/
      vnmovimi            NUMBER;
      vpasexec            NUMBER (8)                      := 1;
      vparam              VARCHAR2 (500)
                       := 'psseguro=' || psseguro || ' pnmovimi=' || pnmovimi;
      vobject             VARCHAR2 (200)
                                     := 'PAC_MD_PRODUCCION.F_TraspasarPoliza';
      detpoliza           ob_iax_detpoliza;
      v_fcancel           DATE;
      v_npoliza_prefijo   NUMBER;
      v_err               NUMBER;
      v_npoliza           NUMBER                          := NULL;
      /* BUG15617:DRA:23/08/2010*/
      v_npoliza_ini       VARCHAR2 (15)                   := NULL;
      /* BUG15617:DRA:23/08/2010*/
      v_npoliza_cnv       NUMBER;                /* BUG15617:DRA:23/08/2010*/
      v_cempres           empresas.cempres%TYPE;
      detpoliza2          ob_iax_detpoliza; /* Bug 21924 - MDS - 20/06/2012*/
            /* BUG 24685 2013-02-15 AEG se definen 3 variables*/
      v_ctipoasignum      estseguros.ctipoasignum%TYPE;
      v_npreimpreso       estseguros.npreimpreso%TYPE;
      v_npolizamanual     estseguros.npolizamanual%TYPE;
      /* fin BUG 24685 2013-02-15 AEG se definen 3 variables*/
      vcmovseg            codimotmov.cmovseg%TYPE;
      /* BUG 0035409 - FAL - 15/04/2015*/
      v_creteni           seguros.creteni%TYPE;
   BEGIN
      /*Comprovació dels parámetres d'entrada*/
      IF psseguro IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      /* BUG 24685 2013-02-15 AEG se asignan 3 variables*/
      SELECT e.sproduc, e.cramo, e.fefecto, e.nsolici, e.ssegpol,
             e.polissa_ini, e.cempres, e.ctipoasignum, e.npreimpreso,
             e.npolizamanual
        INTO vsproduc, vcramo, vfefecto, vnsolici, vssegpol,
             v_npoliza_ini, v_cempres, v_ctipoasignum, v_npreimpreso,
             v_npolizamanual
        FROM estseguros e
       WHERE e.sseguro = psseguro;

      /* fin BUG 24685 2013-02-15 AEG se asignan 3 variables*/
      /*Comprovo si estic tractant el trapÃ s d'una proposta d'alta de pólissa, o d'una proposta de suplement.*/
      SELECT DECODE (COUNT ('x'), 0, 'ALTA', 'SUPL')
        INTO vmode
        FROM seguros s
       WHERE s.sseguro = vssegpol AND s.csituac <> 4;          /*//psseguro;*/

      /*Processem el traspÃ s d'una proposta d'alta o de suplement.*/
      IF vmode = 'ALTA'
      THEN
         vpasexec := 5;

         /* BUG15617:DRA:23/08/2010:Inici*/
         /* Comprovem si donem el número de pólissa o de sol licitud segons producte.*/
         IF NVL (f_parproductos_v (vsproduc, 'NPOLIZA_EN_EMISION'), 0) = 1
         THEN
            /* El número de la pólissa es dóna a l'emissió. Ara assignem el de sol licitud.*/
            vpasexec := 6;

            /* BUG 24685 2013-02-15 AEG se usan*/
            IF NVL (v_npreimpreso, 0) <> 0
            THEN
               /* MANUAL*/
               UPDATE estseguros e
                  SET e.nsolici = v_npreimpreso
                WHERE e.sseguro = psseguro;

               v_err := pac_prod_comu.f_asignarango (1, vcramo, v_npreimpreso);

               IF v_err <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_err);
                  RAISE e_object_error;
               END IF;
            ELSE
               IF vnsolici IS NULL
               THEN
                  /* BUG 0019332 - 30/08/2011 - JMF*/
                  vnsolici := pac_propio.f_numero_solici (v_cempres, vcramo);

                  UPDATE estseguros e
                     SET e.nsolici = vnsolici
                   WHERE e.sseguro = psseguro;
               END IF;
            END IF;
         /* fin BUG 24685 2013-02-15 AEG se usan*/
         ELSE
            vpasexec := 7;
            v_npoliza_cnv :=
                   NVL (f_parproductos_v (vsproduc, 'NPOLIZA_CNVPOLIZAS'), 0);

            IF v_npoliza_cnv IN (1, 2)
            THEN
               num_err := 0;

               /* BUG16372:DRA:19/10/2010:Inici*/
               IF LENGTH (v_npoliza_ini) > 8
               THEN
                  num_err := 9901434;
               /* El número de pólissa ha de ser numÃ¨ric i de 8 dÃ­gits com a mÃ xim*/
               END IF;

               BEGIN
                  v_npoliza := TO_NUMBER (v_npoliza_ini);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     num_err := 9901434;
               /* El número de pólissa ha de ser numÃ¨ric i de 8 dÃ­gits com a mÃ xim*/
               END;

               IF num_err <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
                  RAISE e_object_error;
               END IF;

               /* BUG16372:DRA:19/10/2010:Fi*/
               IF v_npoliza IS NULL AND v_npoliza_cnv = 2
               THEN
                  /* El numero de póliza inicial debe estar informado*/
                  num_err := 120006;
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
                  RAISE e_object_error;
               END IF;
            END IF;

            vpasexec := 8;

            IF v_npoliza IS NULL AND num_err = 0
            THEN
               /* Bug 9720 - APD - 28/04/2009 - Antes de llamar a la función f_contador se deberá verificar el parproducto*/
               /* 'NPOLIZA_PREFIJO' devuelva un valor. En caso de que no está informado se llamará a la f_contador*/
               /* con el cramo (como se está haciendo en la actualidad), en caso contrario se deberá llamar con el*/
               /* resultado del parproducto*/
               v_npoliza_prefijo :=
                               f_parproductos_v (vsproduc, 'NPOLIZA_PREFIJO');

               IF v_npoliza_prefijo IS NOT NULL
               THEN
                  vcramo := v_npoliza_prefijo;
               END IF;

               /* Bug 9720 - APD - 28/04/2009 - Fin*/
               /* v_npoliza := f_contador('02', vcramo);*/
               /* BUG 17008 - 27/12/2010 - JMP - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nÂ° de póliza*/
               v_npoliza := pac_propio.f_contador2 (v_cempres, '02', vcramo);

               /* ini BUG 0019332 - 30/08/2011 - JMF*/
               DECLARE
                  v_numaddpoliza   NUMBER;
               BEGIN
                  v_numaddpoliza :=
                     pac_parametros.f_parempresa_n (v_cempres,
                                                    'NUMADDPOLIZA');
                  v_npoliza := v_npoliza + NVL (v_numaddpoliza, 0);
               END;
            /* fin BUG 0019332 - 30/08/2011 - JMF*/
            END IF;

            vpasexec := 9;

            /* BUG 24685 2013-02-15 AEG se usan*/
            IF v_ctipoasignum = 1
            THEN
               /* MANUAL*/
               v_npoliza :=
                  pac_prod_comu.f_obtener_polizamanual (vsproduc,
                                                        v_npolizamanual
                                                       );

               IF v_npoliza IS NULL
               THEN
                  RAISE e_object_error;
               END IF;

               v_err :=
                      pac_prod_comu.f_asignarango (2, vcramo, v_npolizamanual);

               IF v_err <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_err);
                  RAISE e_object_error;
               END IF;
            END IF;

            /* fin BUG 24685 2013-02-15 AEG se usan*/
            IF NVL (f_parproductos_v (vsproduc, 'RESPETA_NPOLIZA'), 0) = 0
            THEN
               /* S'adjudica un número de pólissa ja a la proposta de alta*/
               UPDATE estseguros e
                  SET e.npoliza = v_npoliza
                WHERE e.sseguro = psseguro;
            END IF;

            /* BUG 24685 2013-02-15 AEG*/
            IF NVL (v_npreimpreso, 0) <> 0
            THEN
               UPDATE estseguros e
                  SET e.nsolici = v_npreimpreso
                WHERE e.sseguro = psseguro;
            END IF;
         /* fin BUG 24685 2013-02-15 AEG*/
         END IF;

         /* BUG15617:DRA:23/08/2010:Fi*/
         /* BUG9718:DRA:23/04/2009:Inici*/
         vpasexec := 10;
         num_err :=
            pac_clausulas.f_ins_clausulas (psseguro, NULL, pnmovimi, vfefecto);

         IF num_err <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;

         /* BUG9718:DRA:23/04/2009:Fi*/
         /* BUG7701:dra:16-02-2009: Informamos de la fecha de validez de la propuesta*/
         vpasexec := 11;
         num_err := pac_seguros.f_get_set_fcancel (psseguro, 'EST', v_fcancel);

         IF num_err <> 0
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 12;
         /*Trapasem les dades de les taules EST a les taules REALS*/
         /* Bug 21924 - MDS - 20/06/2012*/
         /* tercer parámetro : detpoliza2.gestion.cdomper*/
         detpoliza2 := pac_iobj_prod.f_getpoliza (mensajes);
         pac_alctr126.traspaso_tablas_est (psseguro,
                                           vfefecto,
                                           detpoliza2.gestion.cdomper,
                                           vmens,
                                           'ALCTR126',
                                           NULL,
                                           1,
                                           NULL
                                          );
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_md_produccion',
                      vpasexec,
                      'pac_alctr126.traspaso_tablas_est -->',
                      'wmens' ||vmens
                     );

         IF vmens IS NOT NULL
         THEN
            vpasexec := 13;
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 105419);
            RAISE e_object_error;
         END IF;

         /* UPDATE movseguro*/
         /*    SET nempleado = :bk_usuario.usuario*/
         /*    WHERE sseguro = vssegpol*/
         /*      AND nmovimi = 1;*/
         /* vprimatotal := f_segprima (vssegpol, vfefecto);*/
         /* UPDATE seguros*/
         /*    SET iprianu = vprimatotal*/
         /*    WHERE sseguro = vssegpol;*/
         /*JAVENDANO, si se está guardando el certifcado cero se actualiza NCERTIF a 0*/
         IF NVL (pac_parametros.f_parproducto_n (vsproduc,
                                                 'ADMITE_CERTIFICADOS'
                                                ),
                 0
                ) = 1
         THEN
            SELECT npoliza
              INTO v_npoliza
              FROM seguros
             WHERE sseguro = vssegpol;

            IF pac_seguros.f_soycertifcero (vsproduc, v_npoliza, vssegpol) = 0
            THEN
               UPDATE seguros
                  SET ncertif = 0
                WHERE sseguro = vssegpol;
            END IF;
         END IF;
      /*FIN JAVENDANO*/
      ELSIF vmode = 'SUPL'
      THEN
         /* PENDENT d'implementar el traspÃ s de propostes de suplements.*/
         detpoliza := pac_iobj_prod.f_getpoliza (mensajes);
         vpasexec := 14;

         IF pac_iax_produccion.ismodifprop = FALSE
         THEN
            /* BUG14754:DRA:01/06/2010*/
            /*Obtenemos la fecha de efecto*/
            num_err :=
               pk_suplementos.f_fecha_efecto (psseguro,
                                              NVL (pnmovimi, 1),
                                              fsuplem
                                             );
            vpasexec := 15;

            IF num_err <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
               COMMIT;
               RAISE e_object_error;
            END IF;

            vpasexec := 16;
            /*Obtenemos el motivo del suplemento*/
            /*num_err := pk_suplementos.f_obtener_cmotmov(psseguro, pnmovimi, cmotmov);  -- BUG 0035409 - FAL - 15/04/2015*/
            num_err :=
               pk_suplementos.f_obtener_cmotmov (psseguro, pnmovimi, wcmotmov);
            vpasexec := 17;

            IF num_err <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 18;
         num_err :=
             pac_clausulas.f_ins_clausulas (psseguro, NULL, pnmovimi, fsuplem);
         vpasexec := 19;                             --CONF-249-30/11/2016-RCS

         IF num_err <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;

         vpasexec := 20;                             --CONF-249-30/11/2016-RCS

         SELECT MAX (nmovimi)
           INTO vnmovimi
           FROM movseguro
          WHERE sseguro = vssegpol;

         vpasexec := 21;                             --CONF-249-30/11/2016-RCS

         IF pnmovimi > vnmovimi
         THEN
            detpoliza.csituac := 5;
            detpoliza.nsuplem := NVL (detpoliza.nsuplem, 0) + 1;
            vpasexec := 22;                         --CONF-249-30/11/2016-RCS
            /*Obtenemos el numero de movimiento*/
            /*num_err := f_movseguro(vssegpol, NULL, cmotmov, 1, fsuplem, NULL, -- BUG 0035409 - FAL - 15/04/2015*/
            num_err :=
               f_movseguro (vssegpol,
                            NULL,
                            wcmotmov,
                            1,
                            fsuplem,
                            NULL,
                            detpoliza.nsuplem,
                            0,
                            NULL,
                            vnmovimi
                           );

            IF num_err <> 0
            THEN
               vpasexec := 23;                      --CONF-249-30/11/2016-RCS
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
               RAISE e_object_error;
            END IF;

            vpasexec := 24;                          --CONF-249-30/11/2016-RCS
            num_err := f_act_hisseg (vssegpol, vnmovimi - 1);

            IF num_err <> 0
            THEN
               vpasexec := 25;                      --CONF-249-30/11/2016-RCS
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 26;                             --CONF-249-30/11/2016-RCS
         pac_iobj_prod.p_set_poliza (detpoliza);

         UPDATE estseguros e
            SET e.csituac = detpoliza.csituac,
                e.nsuplem = detpoliza.nsuplem
          WHERE e.sseguro = psseguro;

         vpasexec := 27;                             --CONF-249-30/11/2016-RCS

         /* BUG 0035409 - FAL - 15/04/2015 - informar ffinefe del supl. regularización aunque quede retenida*/
         IF wcmotmov IS NOT NULL
         --BUG 510 01/08/2017 DVA ERROR PLSQL PROPUESTA SUPLEMENTO INICIO
         THEN
            SELECT cmovseg
              INTO vcmovseg
              FROM codimotmov
             WHERE cmotmov = wcmotmov;
         END IF;

         --BUG 510 01/08/2017 DVA ERROR PLSQL PROPUESTA SUPLEMENTO FIN
         vpasexec := 28;                             --CONF-249-30/11/2016-RCS

         IF vcmovseg = 6
         THEN
            BEGIN
               UPDATE estgaranseg
                  SET ffinefe = fsuplem
                WHERE sseguro = psseguro AND nmovimi = vnmovimi;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_md_produccion.f_traspasarpoliza',
                               vpasexec,
                                  'error al modificar garanseg  sseguro ='
                               || psseguro,
                               SQLERRM
                              );
                  RETURN 180385;      /* error al modificar la tabla seguros*/
            END;
         END IF;

         /* FIN BUG 0035409 - FAL - 15/04/2015*/
         COMMIT;
         vpasexec := 29;                             --CONF-249-30/11/2016-RCS
         /* para que se guarde la situación y nsuplem antes de traspasar*/
         pac_alctr126.traspaso_tablas_est (psseguro,
                                           fsuplem,
                                           NULL,
                                           vmens,
                                           'ALSUP003',
                                           NULL,
                                           vnmovimi,
                                           fsuplem
                                          );

         IF vmens IS NOT NULL
         THEN
            vpasexec := 30;                         --CONF-249-30/11/2016-RCS
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 105419, vmens);
            RAISE e_object_error;
         END IF;
      END IF;

      vprimatotal := f_segprima (vssegpol, vfefecto);
      vpasexec := 31;                                --CONF-249-30/11/2016-RCS

      UPDATE seguros
         SET iprianu = vprimatotal
       WHERE sseguro = vssegpol;

      /*BUG 27081_145710 - INICIO - 04/06/2013 - Comentamos las llamadas a la funciones pac_listarestringida.*/
      /* I - 31/10/2012 jlb - 23823*/
      /* Llamo a las listas restringidas*/
      /* Accion: anulaci??e p??a*/
      /*num_err := pac_listarestringida.f_valida_listarestringida(vssegpol,
                                                                NVL(vnmovimi, NVL(pnmovimi, 1)),
                                                                NULL, 4);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := pac_listarestringida.f_valida_listarestringida(vssegpol,
                                                                NVL(vnmovimi, NVL(pnmovimi, 1)),
                                                                NULL, 5);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;*/
      /*BUG 27081_145710 - FIN - 03/06/2013 - Comentamos las llamadas a la funciones pac_listarestringida.*/
      /* F - 31/10/2012- jlb - 23823*/
      pac_alctr126.borrar_tablas_est (psseguro);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_traspasarpoliza;

   /*************************************************************************
      Traspasa una propuesta (de alta o suplemento) de las tablas EST a las tablas REALES
      param in pssolicit  : Número de propuesta
      param out           : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_traspasarpropuesta (
      pssolicit   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr     NUMBER (8)      := 0;
      vsproduc    NUMBER;
      vcramo      NUMBER;
      vfefecto    DATE;
      vssegpol    NUMBER;
      vnsolici    NUMBER;
      vmens       VARCHAR2 (1000);
      vmode       VARCHAR2 (20);
      vpasexec    NUMBER (8)      := 1;
      vparam      VARCHAR2 (500)
         :=    'parámetros - pssolicit: '
            || pssolicit
            || ' - pnmovimi: '
            || pnmovimi;
      vobject     VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.F_TraspasarPropuesta';
      existmot    NUMBER;
      vparampsu   NUMBER;
   BEGIN
      /*Comprovació dels parámetres d'entrada*/
      IF pssolicit IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      DELETE      motretencion m
            WHERE sseguro = pssolicit
              AND m.nmovimi = pnmovimi
              AND m.nriesgo = 1
              AND m.cmotret = 6
              AND NOT EXISTS (
                     SELECT 1
                       FROM motreten_rev r
                      WHERE r.sseguro = m.sseguro
                        AND r.nmovimi = m.nmovimi
                        AND r.nriesgo = 1
                        AND r.cmotret = 6
                        AND m.nmotret = r.nmotret);

      /*Solución temporal. Se prepara para el arranque de AGM. Más adelante se deberá hacer correctamente, en lugar de mirar el mottivo de retención 20. #XPL#07072011#0020043*/
      SELECT COUNT (1)
        INTO existmot
        FROM estmotretencion
       WHERE sseguro = pssolicit AND nmovimi = pnmovimi AND cmotret = 20;

      SELECT sproduc
        INTO vsproduc
        FROM estseguros
       WHERE sseguro = pssolicit;

      vparampsu := pac_parametros.f_parproducto_n (vsproduc, 'PSU');

      IF existmot = 0 AND NVL (vparampsu, 0) = 0
      THEN
         /*Retenció manual de la pólissa*/
         vnumerr :=
            pk_nueva_produccion.f_motivo_retencion (pssolicit, 1, pnmovimi,
                                                    1);

         IF vnumerr > 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSIF NVL (vparampsu, 0) = 1
      THEN
         UPDATE estseguros
            SET creteni = 1                         /*{Retención voluntaria}*/
          WHERE sseguro = pssolicit;
      END IF;

      vpasexec := 5;
      /*TraspÃ s de la polissa*/
      vnumerr := f_traspasarpoliza (pssolicit, pnmovimi, mensajes);

      IF vnumerr > 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_traspasarpropuesta;

   /*************************************************************************
      Retiende una propuesta (de alta o suplemento).
      param in pssolicit  : Número de propuesta
      param out           : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_retenerpropuesta (
      pssolicit   IN       NUMBER,
      pnmovimi    IN       NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr             NUMBER (8)      := 0;
      vsproduc            NUMBER;
      vcramo              NUMBER;
      vfefecto            DATE;
      vssegpol            NUMBER;
      vnsolici            NUMBER;
      vmens               VARCHAR2 (1000);
      vmode               VARCHAR2 (20);
      vpasexec            NUMBER (8)      := 1;
      vparam              VARCHAR2 (500)
         :=    'parÃ¡metros - pssolicit: '
            || pssolicit
            || ' - pnmovimi: '
            || pnmovimi;
      vobject             VARCHAR2 (200)
                                     := 'PAC_MD_PRODUCCION.F_RetenerPropuesta';
      -- INI - 4820 - ML - CREACION DE VARIABLES
      aplicafacultativo   NUMBER          := 0;
      -- BANDERA PARA VERIFICAR FACULTATIVO
      numeropoliza        NUMBER          := 0;
      -- PARA GUARDAR EL NUMERO DE POLIZA
      numeroseguro        NUMBER          := 0;
      -- PARA GUARDAR EL NUMERO DE SEGURO
      codigofacultativo   NUMBER          := 0;
      -- PARA ALMACERNAR SIGUIENTE FACULTATIVO
      cuafaculanterior    NUMBER;                 -- GUARDAR REGISTRO ANTERIOR
   -- FIN - 4820 - ML - CREACION DE VARIABLES
   BEGIN
      /*ComprovaciÃ³ dels parÃ¡metres d'entrada*/
      IF pssolicit IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      DELETE      motretencion m
            WHERE sseguro = pssolicit
              AND m.nmovimi = pnmovimi
              AND m.nriesgo = 1
              AND m.cmotret = 6
              AND NOT EXISTS (
                     SELECT 1
                       FROM motreten_rev r
                      WHERE r.sseguro = m.sseguro
                        AND r.nmovimi = m.nmovimi
                        AND r.nriesgo = 1
                        AND r.cmotret = 6
                        AND m.nmotret = r.nmotret);

      vpasexec := 5;

       -- INI - 4820,5013 - ML - SI EL MOVIMIENTO ES DIFERENTE DE 1, OSEA MOV VERIFICO FACULTATIVO
      -- CREATE FAC PENDIENTE PARA TODOS LOS CASOS
      IF pnmovimi > 1
      THEN
--         -- BUSCAR NUMERO SEGURO
         BEGIN
            SELECT npoliza
              INTO numeropoliza
              FROM estseguros
             WHERE sseguro = pssolicit AND ROWNUM = 1;

            SELECT sseguro
              INTO numeroseguro
              FROM seguros
             WHERE npoliza = numeropoliza AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE e_param_error;
         END;
      END IF;

      /*TraspÃƒÂ s de la polissa*/
      vnumerr := f_traspasarpoliza (pssolicit, pnmovimi, mensajes);

      IF vnumerr > 0
      THEN
         RAISE e_object_error;
      END IF;

      IF pnmovimi > 1 AND numeroseguro IS NOT NULL
      THEN
         -- VERIFICAR SI NECEISTA FAC EN LOS CONTROLES
         SELECT COUNT (1)
           INTO aplicafacultativo
           FROM psucontrolseg
          WHERE nvalor = 1
            AND nvalorinf = 1
            AND nvalorsuper = 1
            AND nvalortope = 1
            AND ccontrol = 526031
            AND nmovimi = pnmovimi
            AND sseguro = numeroseguro;

         IF aplicafacultativo > 0
         THEN
            -- BUSCO REGISTRO CON MOV ANTERIOR PARA COPIAR DATOS
            --
            -- Inicio IAXIS-12992 27/04/2020
            --
            BEGIN
               SELECT sfacult
                 INTO cuafaculanterior
                 FROM cuafacul
                WHERE nmovimi = pnmovimi - 1
                  AND sseguro = numeroseguro
                  AND ROWNUM = 1;

               UPDATE cuafacul
                  SET ffincuf = TRUNC (SYSDATE)
                WHERE sfacult = cuafaculanterior;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
         --
         -- Fin IAXIS-12992 27/04/2020
         --
         END IF;
      END IF;

      -- FIN - 4820, 5013 - ML - SI EL MOVIMIENTO ES DIFERENTE DE 1, OSEA MOV VERIFICO FACULTATIVO
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_retenerpropuesta;

   /*************************************************************************
      Establece la fecha de efecto de la póliz en función de la parametrización
      del producto y de la fecha de efecto de la póliza
      param in psproduc    : código del producto
      param in out pfefecto: fecha de efecto del producto
      param in out mensajes: mensajes de error
      return               : 0 todo correcto
                             1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_calc_fefecto (
      psproduc   IN       NUMBER,
      pfefecto   IN OUT   DATE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER (8)     := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
          := 'parametros: sproduc =' || psproduc || ' pfefecto =' || pfefecto;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Set_Calc_Fefecto';
   BEGIN
      /*Comprovació de parÃ metres erronis*/
      IF psproduc IS NULL OR pfefecto IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      /* BUG 10549 - 26/06/2009 - ETM - Fecha de efecto fija para un producto--INI*/
      IF pac_parametros.f_parproducto_f (psproduc, 'DIA_EFECTO') IS NOT NULL
      THEN
         pfefecto := pac_parametros.f_parproducto_f (psproduc, 'DIA_EFECTO');
      /* BUG 10549 - 26/06/2009 - ETM - Fecha de efecto fija para un producto--FIN*/
      ELSIF NVL (f_parproductos_v (psproduc, 'DIA_INICIO_01'), 0) IN (1, 3)
      THEN
         /* la fecha de efecto será el 1 del mes en curso*/
         pfefecto :=
            TO_DATE ('01' || TO_CHAR ((LAST_DAY (pfefecto) + 1), 'mmyyyy'),
                     'ddmmyyyy'
                    );
      ELSIF NVL (f_parproductos_v (psproduc, 'DIA_INICIO_01'), 0) IN (2, 4)
      THEN
         /* la fecha de efecto será el 1 del mes en curso*/
         pfefecto :=
                   TO_DATE ('01' || TO_CHAR (pfefecto, 'mmyyyy'), 'ddmmyyyy');
      ELSIF     NVL (f_parproductos_v (psproduc, 'DIA_INICIO_01'), 0) IN (5)
            AND TO_NUMBER (TO_CHAR (f_sysdate, 'dd')) <= 15
      THEN
         /* la fecha de efecto será el 1 del mes en curso*/
         pfefecto :=
                   TO_DATE ('01' || TO_CHAR (pfefecto, 'mmyyyy'), 'ddmmyyyy');
      ELSIF     NVL (f_parproductos_v (psproduc, 'DIA_INICIO_01'), 0) IN (5)
            AND TO_NUMBER (TO_CHAR (f_sysdate, 'dd')) > 15
      THEN
         /* la fecha de efecto será el 1 del mes en curso*/
         pfefecto :=
            TO_DATE ('01' || TO_CHAR ((LAST_DAY (pfefecto) + 1), 'mmyyyy'),
                     'ddmmyyyy'
                    );
      /* Bug 18085 - APD - 04/04/2011 - La fecha de efecto seriija para un dia y mes del año en curso*/
      ELSIF pac_parametros.f_parproducto_t (psproduc, 'DIA_MES_EFECTO') IS NOT NULL
      THEN
         pfefecto :=
            TO_DATE (   pac_parametros.f_parproducto_t (psproduc,
                                                        'DIA_MES_EFECTO'
                                                       )
                     || TO_CHAR (pfefecto, 'yyyy'),
                     'ddmmyyyy'
                    );
      /* Fin Bug 18085 - APD - 04/04/2011*/
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_calc_fefecto;

   /*************************************************************************
      Establece la fecha de vencimiento y la duración de la póliza, si estuvieran
      informados los datos no hace nada
      param in pgest  : datos de gestión
      param out       : mensajes de error
      return          : 0 todo correcto
                        1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_calc_vencim_nduraci (
      pgest      IN OUT   ob_iax_gestion,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      ries         t_iax_riesgos;
      rie          ob_iax_riesgos;
      nperson      NUMBER;
      minfnacim    DATE;
      fnacimper    DATE;
      nerr         NUMBER;
      det_poliza   ob_iax_detpoliza;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (500)   := 'parámetros - datos de gestión';
      vobject      VARCHAR2 (200)
                             := 'PAC_MD_PRODUCCION.F_Set_Calc_Vencim_Nduraci';
   BEGIN
      /* ACC 26052088 HA DE FER SEMPRE EL CALCUL DE VENCIMENTS*/
      /*        IF pgest.fefecto is not null and pgest.duracion is not null THEN*/
      /*            RETURN 0;*/
      /*        END IF;*/
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.p_grabadberror
                                      (vobject,
                                       2,
                                       'No puede recuperar el objeto poliza',
                                       'deT_poliza'
                                      );
         RETURN 0;
      END IF;

      ries := pac_iobj_prod.f_partpolriesgos (det_poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 2;
            RAISE e_object_error;
         END IF;
      END IF;

      IF ries IS NOT NULL
      THEN
         IF ries.COUNT > 0
         THEN
            FOR vrie IN ries.FIRST .. ries.LAST
            LOOP
               IF ries.EXISTS (vrie)
               THEN
                  IF det_poliza.cobjase = 1
                  THEN
                     /* PERSONALS*/
                     IF ries (vrie).riespersonal IS NOT NULL
                     THEN
                        IF ries (vrie).riespersonal.COUNT > 0
                        THEN
                           FOR vrper IN
                              ries (vrie).riespersonal.FIRST .. ries (vrie).riespersonal.LAST
                           LOOP
                              IF ries (vrie).riespersonal.EXISTS (vrper)
                              THEN
                                 nperson :=
                                    NVL
                                       (ries (vrie).riespersonal (vrper).sperson,
                                        0
                                       );

                                 IF nperson > 0
                                 THEN
                                    /*fnacimPer:=PAC_IAX_LISTVALORES.F_GETDESCRIPVALOR('SELECT FNACIMI FROM PERSONAS WHERE SPERSON='||NPERSON,MENSAJES);*/
                                    fnacimper :=
                                       ries (vrie).riespersonal (vrper).fnacimi;

                                    IF fnacimper < NVL (minfnacim, f_sysdate)
                                    THEN
                                       minfnacim := fnacimper;
                                    END IF;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      /* Bug 16768 - APD - 22/11/2010 - se añade el parametro pnpoliza*/
      nerr :=
         pac_calc_comu.f_calcula_fvencim_nduraci (det_poliza.sproduc,
                                                  minfnacim,
                                                  pgest.fefecto,
                                                  pgest.cduraci,
                                                  pgest.duracion,
                                                  pgest.fvencim,
                                                  det_poliza.npoliza,
                                                  det_poliza.nrenova,
                                                  pgest.nedamar,
                                                  /* Bug 25584 MMS add NEDAMAR*/
                                                  det_poliza.ncertif
                                                 );         /*PRBMANT-24 AAC*/

      /* Fin Bug 16768 - APD - 22/11/2010 - se añade el parametro pnpoliza*/
      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         RAISE e_object_error;
      END IF;

      /* Mantis 7919.#6.i.*/
      IF pgest.ndurcob IS NULL
      THEN
         nerr :=
            pac_md_produccion.f_set_calc_ndurcob
                                             (det_poliza.sproduc /* entrada*/,
                                              pgest /* entrada/sortida*/,
                                              mensajes    /* entrada/sortida*/
                                             );
      END IF;                                           /* Mantis 7919.#6.f.*/

      IF nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         RAISE e_object_error;
      /**/
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_calc_vencim_nduraci;

   /***********************************************************************
      Cobro de un recibo
      param in pctipcob  : tipo cobro VF 552
      param in pnrecibo  : número de recibo
      param in pcbancar  : cuenta bancaria
      param in pctipban  : tipo cuenta bancaria
      param out mensajes : mensajes de error
      return             : codi error del proceso
   ***********************************************************************/
   FUNCTION f_set_cobrorec (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pctipcob   IN       NUMBER,
      pctipban   IN       NUMBER,
      pcbancar   IN       VARCHAR2,
      pterror    OUT      VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_error          NUMBER                  := 0;
      vpasexec         NUMBER (8)              := 0;
      vparam           VARCHAR2 (500)
         :=    'psseguro '
            || psseguro
            || ' pnmovimi '
            || pnmovimi
            || ' pctipcob '
            || pctipcob
            || ' pcbancar '
            || pcbancar
            || ' pctipban '
            || pctipban;
      vobject          VARCHAR2 (200)    := 'PAC_MD_PRODUCCION.F_Set_CobroRec';
      vcobrado         NUMBER;
      vctipcob         NUMBER;
      vctipcobmov      NUMBER;
      vsinterf         NUMBER;
      vttexto1         VARCHAR2 (100);
      vttexto2         VARCHAR2 (100);
      vsperson         NUMBER (8);
      vcnordban        per_ccc.cnordban%TYPE;
      vcagente_visio   agentes.cagente%TYPE;
      vcagente_per     agentes.cagente%TYPE;
      vcbancar         recibos.cbancar%TYPE;
      vctipban         recibos.ctipban%TYPE;
      vpccobban        NUMBER;

      CURSOR crecib
      IS
         SELECT   r.nrecibo, r.fefecto, r.fvencim, v.itotalr, m.cestrec,
                  r.ctiprec, m.ctipcob, s.cbancar, s.ctipban, s.sseguro,
                  s.ctipcob tipcobseg, s.npoliza, s.cagente, m.fmovini,
                  r.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                  r.cdelega
             FROM recibos r, movrecibo m, vdetrecibos v, seguros s
            WHERE r.sseguro = psseguro
              AND r.nmovimi = pnmovimi
              AND r.nrecibo = m.nrecibo
              AND s.sseguro = r.sseguro
              AND m.smovrec = (SELECT MAX (m2.smovrec)
                                 FROM movrecibo m2
                                WHERE m2.nrecibo = m.nrecibo)
              AND r.nrecibo = v.nrecibo
              AND m.cestrec = 0
              AND r.ctiprec IN (0, 1, 4, 9, 10)
         ORDER BY r.fefecto DESC;
   BEGIN
      vpasexec := 1;

      FOR recib IN crecib
      LOOP
         vctipban := NVL (pctipban, recib.ctipban);
         vcbancar := NVL (pcbancar, recib.cbancar);
         vpasexec := 5;

         /* Actualizamos el tipo de cobro del seguro*/
         IF pctipcob IS NOT NULL AND pctipcob <> recib.tipcobseg
         THEN
            vctipcob := pctipcob;
         ELSE
            vctipcob := recib.tipcobseg;
         END IF;

         IF NVL (pnmovimi, 0) = 1
         THEN
            UPDATE seguros
               SET ctipcob = vctipcob,
                   ctipban = NVL (pctipban, ctipban),
                   cbancar = NVL (pcbancar, cbancar)
             WHERE sseguro = recib.sseguro;
         END IF;

         vpasexec := 7;

         IF vctipcob = 2 AND recib.ctiprec <> 10
         THEN
            /*BUG 10899 - 07/08/2009 - JTS  -- Domiciliación*/
            vctipcobmov := 1;                                   /* Por HOST*/
         ELSIF vctipcob = 1 OR recib.ctiprec = 10
         THEN
            /*BUG 10899 - 07/08/2009 - JTS   -- Caja*/
            vctipcobmov := 0;                                   /* Por Caja*/
         ELSE
            vctipcobmov := NULL;
         END IF;

         /*BUG 10069 - 15/06/2009 - JTS*/
         vpccobban :=
            f_buscacobban (recib.cramo,
                           recib.cmodali,
                           recib.ctipseg,
                           recib.ccolect,
                           recib.cagente,
                           vcbancar,
                           vctipban,
                           v_error
                          );

         IF vpccobban IS NULL
         THEN
            RETURN v_error;
         END IF;

         /*BUG 17435 - 01/02/2011 - JTS*/
         /*SELECT DECODE(vctipcob, 1, 0, vctipcob)
         INTO vctipcob
         FROM DUAL;*/
         v_error :=
            pac_md_gestion_rec.f_cobro_recibo (recib.cempres,
                                               recib.nrecibo,
                                               recib.fmovini,
                                               vctipban,
                                               vcbancar,
                                               vpccobban,
                                               recib.cdelega,
                                               NVL (vctipcobmov, 0),
                                               0,
                                               mensajes
                                              );

         /*FI BUG 17435*/
         /*v_error := pac_prod_comu.f_cobro_recibo(recib.nrecibo, vcbancar, vctipcobmov,
         vctipban);*/
         /*Fi BUG 10069 - 15/06/2009 - JTS*/
         IF v_error <> 0 AND vctipcobmov != 1
         THEN
            pterror :=
                    f_axis_literales (v_error, pac_md_common.f_get_cxtidioma);
            RETURN 1;
         END IF;

         vpasexec := 9;

         IF     recib.ctiprec <> 10
            /*No cobrem a HOST els rebuts de traspÃ s*/
            AND vctipcobmov = 1  /* Solo si el pago es tipo de cobro es HOST*/
         THEN
            /*Cobrament del rebut a HOST*/
            /*v_error := pac_md_con.f_cobro_recibo(recib.nrecibo, vcobrado, vsinterf, pterror,
            mensajes);*/
            IF v_error <> 0
            THEN
               pterror := mensajes (mensajes.LAST).terror;
               mensajes := NULL;
               vttexto1 :=
                    f_axis_literales (9000578, pac_md_common.f_get_cxtidioma);
               /*vttexto2 := f_axis_literales(151332, pac_md_common.f_get_cxtidioma);*/
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     2,
                                                     9000578,
                                                        vttexto1
                                                     || ' '
                                                     || pterror
                                                     || '.'
                                                    );
               RETURN 1;
            ELSE
               /*(JAS) Si el cobro funciona corractament, comprovem si el compte on s'ha realitzat*/
               /*el cobrament estÃ  traspassat a les taules reals.*/
               vpasexec := 11;

               /*Resupero el prenedor de la pólissa*/
               SELECT t.sperson
                 INTO vsperson
                 FROM tomadores t
                WHERE t.sseguro = psseguro AND t.nordtom = 1;

               vpasexec := 13;
               /*Recupero el nivell de visió de l'agent*/
               pac_persona.p_busca_agentes (vsperson,
                                            recib.cagente,
                                            vcagente_visio,
                                            vcagente_per,
                                            'POL'
                                           );
               vpasexec := 15;
               /*Comprovem si el compte existeix*/
               vcnordban :=
                  pac_persona.f_existe_ccc (vsperson,
                                            vcagente_per,
                                            vctipban,
                                            vcbancar
                                           );

               /*Si el compte no existix, el traspassem. Si el compte ja existeix, no cal fer res más*/
               IF vcnordban IS NULL
               THEN
                  v_error :=
                     pac_md_persona.f_set_ccc (vsperson,
                                               vcagente_per,
                                               vcnordban,
                                               vctipban,
                                               vcbancar,
                                               0,
                                               mensajes,
                                               'POL'
                                              );

                  IF v_error <> 0
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           v_error
                                                          );
                     RAISE e_object_error;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_cobrorec;

   /***********************************************************************
      Recupera los recibos de la póliza
      param in psolicit  : número de solicitud
      param out mensajes : mensajes de error
      return             : numero error
   ***********************************************************************/
   FUNCTION f_cobro_recibos (
      psolicit   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pctipcob   IN       NUMBER,
      pctipban   IN       NUMBER,
      pcbancar   IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vidioma     NUMBER          := pac_md_common.f_get_cxtidioma;
      vcrealiza   NUMBER;
      vemision    NUMBER;
      vsproduc    NUMBER;
      vttexto1    VARCHAR2 (100);
      vttexto2    VARCHAR2 (100);
      vttexto3    VARCHAR2 (100);
      vpasexec    NUMBER (8)      := 1;
      vparam      VARCHAR2 (500)
                    := 'psolicit: ' || psolicit || ' - pnmovimi:' || pnmovimi;
      vobject     VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.F_Cobro_Recibos';
      verror      NUMBER;
      verroraux   NUMBER;
      vtextoerr   VARCHAR2 (2000);
   BEGIN
      IF psolicit IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      /* Buscamos el sproduc del seguro*/
      verror := pac_seguros.f_get_sproduc (psolicit, 'POL', vsproduc);

      IF verror <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      /* Se comprueba si el usuario tiene permisos para realizar la accion.*/
      vemision :=
         pac_cfg.f_get_user_accion_permitida (pac_md_common.f_get_cxtusuario,
                                              'EMISION_HOST',
                                              vsproduc,
                                              pac_md_common.f_get_cxtempresa,
                                              /* BUG9981:DRA:07/05/2009*/
                                              vcrealiza
                                             );

      IF vemision = 0
      THEN
         /*El usuario no tiene permisos para cobrar el recibo.*/
         RETURN 0;
      END IF;

      vpasexec := 6;
      /*Cobro del recibo en AXIS*/
      verror :=
         pac_md_produccion.f_set_cobrorec (psolicit,
                                           pnmovimi,
                                           pctipcob,
                                           pctipban,
                                           pcbancar,
                                           vtextoerr,
                                           mensajes
                                          );

      IF verror <> 0
      THEN
         vpasexec := 7;
         ROLLBACK;                       /* dra 28-10-2008: bug mantis 7519*/
         /* Error en l'emissió de la pólissa, retenim la pólissa.*/
         verroraux :=
            pac_emision_mv.f_retener_poliza ('SEG',
                                             psolicit,
                                             1,
                                             pnmovimi,
                                             4,
                                             1,
                                             f_sysdate
                                            );

         IF verroraux <> 0
         THEN
            RAISE e_object_error;
         END IF;

         /*dra 31-10-2008: bug mantis 7519. Ahora cogeremos el mensaje de la función f_set_cobrorec*/
         /*vttexto1 := f_axis_literales (151237, PAC_MD_COMMON.f_get_cxtidioma);*/
         /*vttexto2 := f_axis_literales (151332, PAC_MD_COMMON.f_get_cxtidioma);*/
         /*vttexto3 := f_axis_literales (151333, PAC_MD_COMMON.f_get_cxtidioma);*/
         /*PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,2,151237,vttexto1 ||'. '|| vttexto2 ||': '|| onpoliza || CHR (10) || vttexto3);*/
         RETURN 1;
      END IF;

      vpasexec := 8;
      /*Recibo cobrado correctamente.*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_cobro_recibos;

   /***********************************************************************
      Establece las garantias del producto para insertalas en el riesgo
      param in out gars : objeto garantias
      param in pnmovimi : número de movimiento
      param in out mensajes : mensajes error
      param in pnriesgo : numero de riesgo
      return             : O todo correcto
                           1 ha habido un error
                           -1 o no te canvis
   ***********************************************************************/
   /* Bug 26662 - APD - 16/04/2013 - se añade el pnriesgo a la funcion*/
   FUNCTION p_set_garanprod (
      gars       IN OUT   t_iax_garantias,
      pnmovimi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes,
      pnriesgo   IN       NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      garp                     t_iaxpar_garantias;
      det_poliza               ob_iax_detpoliza;
      nerr                     NUMBER                    := -1;
      nerr_preg                NUMBER;
      vpasexec                 NUMBER (8)                := 1;
      vparam                   VARCHAR2 (1)              := NULL;
      vobject                  VARCHAR2 (200)
                                       := 'PAC_MD_PRODUCCION.P_Set_GaranProd';
      v_cont                   NUMBER;
      /* Bug 21786 - APD - 11/04/2012*/
      v_contrata_gar_defecto   NUMBER;
      /*Bug 21846 - APD - 29/03/2012*/
      vtablas                  VARCHAR2 (20);
      /*Bug 26662 - APD - 10/04/2013*/
      vcplan                   codplanbenef.cplan%TYPE;
      /*Bug 26662 - APD - 10/04/2013*/
      vicapital                NUMBER;
      /*Bug 26662 - APD - 10/04/2013*/
      vnpos                    NUMBER;
      /*Bug 26662 - APD - 10/04/2013*/
      vresp_9094               NUMBER;
      /*Bug 27923 - DCT - 18/09/2013*/
      vnpos2                   NUMBER;
      vplancol                 NUMBER;
      xxsesion                 NUMBER;
      vresultado               NUMBER;
      vnmeses                  NUMBER;          -- IAXIS-5222 CJMR 04/09/2019

      /* comproba que el codigo de garantia no exista*/
      /* devuelve la posición del indice o bien -1 sino existe*/
      FUNCTION existgar (cgarant IN NUMBER)
         RETURN NUMBER
      IS
      BEGIN
         IF gars IS NULL
         THEN
            RETURN -1;
         END IF;

         IF gars.COUNT = 0
         THEN
            RETURN -1;
         END IF;

         FOR vgar IN gars.FIRST .. gars.LAST
         LOOP
            IF gars.EXISTS (vgar)
            THEN
               IF gars (vgar).cgarant = cgarant
               THEN
                  RETURN vgar;
               END IF;
            END IF;
         END LOOP;

         RETURN -1;
      END existgar;

      /* BUG8947:DRA:14/07/2009:Inici:Buscamos si el padre está marcado*/
      FUNCTION padre_marcado (pcgarant IN NUMBER)
         RETURN NUMBER
      IS
         CURSOR c_padre
         IS
            SELECT g.cgardep
              FROM garanpro g
             WHERE g.cramo = det_poliza.cramo
               AND g.cmodali = det_poliza.cmodali
               AND g.ctipseg = det_poliza.ctipseg
               AND g.ccolect = det_poliza.ccolect
               AND g.cactivi = det_poliza.gestion.cactivi
               AND g.cgarant = pcgarant;

         v_cgardep   NUMBER (4);
      BEGIN
         IF gars IS NULL
         THEN
            RETURN 0;
         END IF;

         IF gars.COUNT = 0
         THEN
            RETURN 0;
         END IF;

         OPEN c_padre;

         FETCH c_padre
          INTO v_cgardep;

         CLOSE c_padre;

         FOR vgar IN gars.FIRST .. gars.LAST
         LOOP
            IF gars.EXISTS (vgar)
            THEN
               IF gars (vgar).cgarant = v_cgardep
               THEN
                  RETURN gars (vgar).cobliga;
               END IF;
            END IF;
         END LOOP;

         RETURN 0;
      END padre_marcado;
   /* BUG8947:DRA:14/07/2009:Fi*/
   BEGIN
      IF gars IS NULL
      THEN
         gars := t_iax_garantias ();
      END IF;

      /* Bug 21786 - APD - 11/04/2012 - nos guardamos el número de garantias que hay*/
      /* en el objeto t_iax_garantias*/
      v_cont := gars.COUNT;
      /* fin Bug 21786 - APD - 11/04/2012*/
      vpasexec := 1;
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        32332,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      /*Bug 26662 - APD - 10/04/2013 - se busca si la poliza tiene plan de beneficio*/
      IF det_poliza.ssegpol IS NOT NULL
      THEN
         vtablas := 'EST';
      ELSE
         vtablas := 'POL';
      END IF;

      /* Obtenemos el Plan del colectivo si lo tiene!!!*/
      IF     pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
      THEN
         FOR i IN
            pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
         LOOP
            IF pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun =
                                                                         4089
            THEN
               vplancol :=
                   pac_iax_produccion.poliza.det_poliza.preguntas (i).crespue;
            END IF;
         END LOOP;
      END IF;

      vcplan :=
         pac_planbenef.f_get_planbenef (vtablas,
                                        det_poliza.sseguro,
                                        pnriesgo,
                                        pnmovimi
                                       );
      vpasexec := 3;
      /*fin Bug 26662 - APD - 10/04/2013*/
      garp := pac_iaxpar_productos.f_get_garantias (pnriesgo, mensajes);

      IF garp IS NOT NULL
      THEN
         vpasexec := 11;

         IF garp.COUNT > 0
         THEN
            vpasexec := 12;

            FOR vgar IN garp.FIRST .. garp.LAST
            LOOP
               vpasexec := 13;

               IF garp.EXISTS (vgar)
               THEN
                  vpasexec := 14;
                  vnpos := existgar (garp (vgar).cgarant);

                  /* Bug 26662 - APD - 17/04/2013*/
                  IF vnpos
                          /*existgar(garp(vgar).cgarant)*/
                     = -1
                  THEN
                     nerr := 0;
                     /* te canvis*/
                     vpasexec := 15;
                     gars.EXTEND;
                     gars (gars.LAST) := ob_iax_garantias ();
                     gars (gars.LAST).cgarant := garp (vgar).cgarant;
                     gars (gars.LAST).nmovimi := pnmovimi;
                     gars (gars.LAST).nmovima := pnmovimi;
                     gars (gars.LAST).ctipgar := garp (vgar).ctipgar;
                     gars (gars.LAST).cobliga := 0;
                     gars (gars.LAST).icapital := NULL;
                     gars (gars.LAST).finiefe := det_poliza.gestion.fefecto;
                     gars (gars.LAST).norden := garp (vgar).norden;
                     -- INI BUG 41143/229973 - 17/03/2016 - JAEG
                     gars (gars.LAST).excontractual :=
                        NVL
                           (pac_iaxpar_productos.f_get_pargarantia
                                                   ('EXCONTRACTUAL',
                                                    det_poliza.sproduc,
                                                    garp (vgar).cgarant,
                                                    det_poliza.gestion.cactivi
                                                   ),
                            0
                           );

                     --
                     IF gars (gars.LAST).excontractual = 0
                     THEN
                        --
                        gars (gars.LAST).finivig :=
                                                   det_poliza.gestion.fefecto;
                        gars (gars.LAST).ffinvig :=
                                                   det_poliza.gestion.fvencim;
                     --
                     ELSIF gars (gars.LAST).excontractual = 1
                     THEN
                        -- INI IAXIS-5222 CJMR 04/09/2019
                        vnmeses :=
                           NVL
                              (pac_iaxpar_productos.f_get_pargarantia
                                                   ('TIEMPO_POSTCONTR_LEY',
                                                    det_poliza.sproduc,
                                                    garp (vgar).cgarant,
                                                    det_poliza.gestion.cactivi
                                                   ),
                               0
                              );
                        gars (gars.LAST).finivig := det_poliza.gestion.fefecto;
                        gars (gars.LAST).ffinvig :=
                           ADD_MONTHS (det_poliza.gestion.fvencplazo, vnmeses);
                     -- FIN IAXIS-5222 CJMR 04/09/2019
                     ELSE
                        -- INI IAXIS-5222 CJMR 04/09/2019
                        gars (gars.LAST).finivig :=
                                                det_poliza.gestion.fvencplazo;
                        gars (gars.LAST).ffinvig :=
                                                   det_poliza.gestion.fvencim;
                     -- FIN IAXIS-5222 CJMR 04/09/2019
                     END IF;

                     --
                     IF NVL
                           (pac_iaxpar_productos.f_get_parproducto
                                                           ('VIGENCIA_AMPARO',
                                                            det_poliza.sproduc
                                                           ),
                            0
                           ) = 0
                     THEN
                        --
                        gars (gars.LAST).finivig := NULL;
                        gars (gars.LAST).ffinvig := NULL;
                     --
                     END IF;

                     --
                     -- FIN BUG 41143/229973 - 17/03/2016 - JAEG
                     /*JRH 11/2008*/
                     IF NVL (garp (vgar).crevali, 0) <> 0
                     THEN
                        /*JRH De momento si la garantÃ­a revaloriza le ponemos la de la póliza*/
                        gars (gars.LAST).crevali := det_poliza.crevali;
                        gars (gars.LAST).prevali := det_poliza.prevali;
                     ELSE
                        gars (gars.LAST).crevali := garp (vgar).crevali;
                        gars (gars.LAST).prevali := garp (vgar).prevali;
                     END IF;

                     /*JRH 03/2008*/
                     gars (gars.LAST).ctipo :=
                        pac_iaxpar_productos.f_get_pargarantia
                                                   ('TIPO',
                                                    det_poliza.sproduc,
                                                    garp (vgar).cgarant,
                                                    det_poliza.gestion.cactivi
                                                   );
                     /* BUG 0036730 - FAL - 09/12/2015*/
                     gars (gars.LAST).cdetalle :=
                        pac_mdpar_productos.f_get_detallegar
                                                          (det_poliza.sproduc,
                                                           garp (vgar).cgarant,
                                                           mensajes
                                                          );
                     /*JRH*/
                     vpasexec := 16;

                     IF garp (vgar).ctipgar = 2
                     THEN
                        /* indica que la garantia es obligatoria*/
                        /* 2 obligatoria*/
                        gars (gars.LAST).cobliga := 1;
                     END IF;

                     /*Bug 26662 - APD - 10/04/2013 - si existe plan de beneficio, se debe mirar*/
                     /* si la garantia pertence al plan, en ese caso, la garantia debe ser siempre*/
                     /* obligatoria*/
                     IF vcplan IS NOT NULL
                     THEN
                        IF pac_planbenef.f_garant_planbenef
                                                     (det_poliza.cempres,
                                                      vcplan,
                                                      1,
                                                      gars (gars.LAST).cgarant
                                                     ) = 1
                        THEN
                           gars (gars.LAST).ctipgar := 2;
                           gars (gars.LAST).cobliga := 1;
                        END IF;
                     END IF;

                     /* fin Bug 26662 - APD - 10/04/2013*/
                     /* Se llama a la funcion que rellena la preguntas por garantÃ­a.*/
                     nerr_preg :=
                        p_set_garanpregunprod (gars (gars.LAST).preguntas,
                                               garp (vgar).cgarant,
                                               pnmovimi,
                                               mensajes
                                              );
                     /*17988: AGM003 - Modificación pantalla garantias (axisctr007).*/
                     gars (gars.LAST).cpartida := garp (vgar).cpartida;
                     gars (gars.LAST).cvisniv := garp (vgar).cvisniv;
                     gars (gars.LAST).cgarpadre := garp (vgar).cgarpadre;
                     gars (gars.LAST).cnivgar := garp (vgar).cnivgar;
                     gars (gars.LAST).cvisible := garp (vgar).cvisible;
                     /*Bug 21846 - APD - 29/03/2012 - se deben marcar como obligatorias*/
                     /* aquellas garantias parametrizadas*/
                     v_contrata_gar_defecto :=
                        NVL
                           (pac_parametros.f_pargaranpro_n
                                                  (det_poliza.sproduc,
                                                   det_poliza.gestion.cactivi,
                                                   gars (gars.LAST).cgarant,
                                                   'CONTRATADA_DEFECTO'
                                                  ),
                            0
                           );

                     /* v_contrata_gar_defecto*/
                     /* 0.- No*/
                     /* 1.- SÃ­, en contratación*/
                     /* 2.- SÃ­, en contratación y suplementos*/
                     /* Si 1.- SÃ­, en contratación y pnmovimi = 1 (contratacion)*/
                     /* o 2.- SÃ­, en contratación y suplementos*/
                     /* entonces marcar la garantia como obligatoria, es decir, seleccionada*/
                     IF    (v_contrata_gar_defecto = 1 AND pnmovimi = 1)
                        OR (v_contrata_gar_defecto = 2)
                        OR (garp (vgar).cdefecto = 1)
                     THEN
                        gars (gars.LAST).cobliga := 1;
                     END IF;

/*--------------------------------------------------------------------------*/
                     IF     NVL (f_parproductos_v (det_poliza.sproduc,
                                                   'ADMITE_CERTIFICADOS'
                                                  ),
                                 0
                                ) = 1
                        AND NOT pac_iax_produccion.isaltacol
                     THEN
                        /*pac_seguros.f_get_escertifcero(det_poliza.npoliza) = 0 THEN*/
                        vresp_9094 :=
                           f_get_obligaopcional_cero (det_poliza.npoliza,
                                                      vcplan,
                                                      garp (vgar).cgarant,
                                                      mensajes
                                                     );

                        /*Si la garantia tiene el ctipgar = 1 (opcional) y en la pregunta 9094 se ha contestado 1 -Obligatoria*/
                        /*la ponemos obligatoria y que se muestre chekeada.*/
                        IF garp (vgar).ctipgar = 1 AND vresp_9094 = 1
                        THEN
                           gars (gars.LAST).ctipgar := 2;
                           gars (gars.LAST).cobliga := 1;
                        END IF;

                        /*Si la garantia tiene el ctipgar = 3 (Dependiente opcional) y en la pregunta 9094 se ha contestado 1 -Obligatoria*/
                        /*la ponemos obligatoria*/
                        IF garp (vgar).ctipgar = 3 AND vresp_9094 = 1
                        THEN
                           gars (gars.LAST).ctipgar := 4;
                        /*gars(gars.LAST).cobliga := 1;*/
                        END IF;

                        /*Si la garantia tiene el ctipgar = 5 (Dependiente opcional multiple) y en la pregunta 9094 se ha contestado 1 -Obligatoria*/
                        /*la ponemos obligatoria*/
                        IF garp (vgar).ctipgar = 5 AND vresp_9094 = 1
                        THEN
                           gars (gars.LAST).ctipgar := 6;
                        /*gars(gars.LAST).cobliga := 1;*/
                        END IF;

                        IF garp (vgar).ctipgar = 4
                        THEN
                           vnpos := existgar (garp (vgar).cgardep);

                           IF gars (vnpos).cobliga = 1
                           THEN
                              gars (gars.LAST).cobliga := 1;
                           END IF;
                        END IF;
                     END IF;

/*----------------------------------------------------------------------------*/
/*fin Bug 21846 - APD - 29/03/2012*/
/* Bug 21786 - APD - 11/04/2012  -*/
                     IF gars (gars.LAST).cobliga = 1
                     THEN
                        /* se cambia de lugar en el codigo, debe ir aqui, al final del IF existgar(garp(vgar).cgarant) = -1 THEN*/
                        IF garp (vgar).ctipcap = 1
                        THEN
                           /* indica que el capital es fitxe i sha de mostrar el valor del capital*/
                           gars (gars.LAST).icapital := garp (vgar).icapmax;
                        /* Ini Bug 21707 - 20/03/2012 - MDS*/
                        ELSIF garp (vgar).ctipcap = 2
                        THEN
                           gars (gars.LAST).icapital :=
                              pac_parametros.f_pargaranpro_n
                                                 (det_poliza.sproduc,
                                                  det_poliza.gestion.cactivi,
                                                  gars (gars.LAST).cgarant,
                                                  'VALORDEFCAPITALGARAN'
                                                 );
                        /* fin Bug 21707 - 20/03/2012 - MDS*/
                        /* Bug 21656 - APD - 12/06/2012 - el capital depende de una lista de valores*/
                        /* se debe mostrar el capital marcado por defecto (es lo mismo que se hace*/
                        /* desde pantalla)*/
                        ELSIF garp (vgar).ctipcap = 7
                        THEN
                           /*Bug 26662 - APD - 10/04/2013 - si existe plan de beneficio se debe mirar*/
                           /* si existe valor de capital para la garantia*/
                           IF vcplan IS NOT NULL
                           THEN
                              gars (gars.LAST).icapital :=
                                 pac_planbenef.f_capital_planbenef
                                                     (det_poliza.cempres,
                                                      vcplan,
                                                      2,
                                                      gars (gars.LAST).cgarant
                                                     );
                           END IF;

                           IF gars (gars.LAST).icapital IS NULL
                           THEN
                              /* fin Bug 26662 - APD - 10/04/2013*/
                              IF garp (vgar).icapdef IS NOT NULL
                              THEN
                                 gars (gars.LAST).icapital :=
                                                          garp (vgar).icapdef;
                              ELSIF garp (vgar).ccapdef IS NOT NULL
                              THEN
                                 FOR j IN
                                    det_poliza.riesgos.FIRST .. det_poliza.riesgos.LAST
                                 LOOP
                                    IF (    det_poliza.riesgos (j).nriesgo =
                                                                      pnriesgo
                                        AND det_poliza.nmovimi = pnmovimi
                                       )
                                    THEN
                                       SELECT sgt_sesiones.NEXTVAL
                                         INTO xxsesion
                                         FROM DUAL;

                                       nerr :=
                                          pac_calculo_formulas.calc_formul
                                               (det_poliza.gestion.fefecto,
                                                det_poliza.sproduc,
                                                det_poliza.riesgos (j).cactivi,
                                                garp (vgar).cgarant,
                                                pnriesgo,
                                                det_poliza.sseguro,
                                                garp (vgar).ccapdef,
                                                vresultado,
                                                pnmovimi,
                                                xxsesion,
                                                1,
                                                det_poliza.gestion.fefecto,
                                                'R',
                                                NULL,
                                                1
                                               );
                                       EXIT;
                                    END IF;
                                 END LOOP;

                                 IF vresultado IS NOT NULL
                                 THEN
                                    gars (gars.LAST).icapital := vresultado;
                                 END IF;
                              ELSE
                                 /* indica que el capital es fitxe i sha de mostrar el valor del capital*/
                                 BEGIN
                                    SELECT icapital
                                      INTO gars (gars.LAST).icapital
                                      FROM garanprocap
                                     WHERE cramo = det_poliza.cramo
                                       AND cmodali = det_poliza.cmodali
                                       AND ctipseg = det_poliza.ctipseg
                                       AND ccolect = det_poliza.ccolect
                                       AND cgarant = gars (gars.LAST).cgarant
                                       AND cdefecto = 1;
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       BEGIN
                                          SELECT icapital
                                            INTO gars (gars.LAST).icapital
                                            FROM garanprocap g
                                           WHERE cramo = det_poliza.cramo
                                             AND cmodali = det_poliza.cmodali
                                             AND ctipseg = det_poliza.ctipseg
                                             AND ccolect = det_poliza.ccolect
                                             AND cgarant =
                                                      gars (gars.LAST).cgarant
                                             AND norden =
                                                    (SELECT MIN (g2.norden)
                                                       FROM garanprocap g2
                                                      WHERE g.cramo = g2.cramo
                                                        AND g.cmodali =
                                                                    g2.cmodali
                                                        AND g.ctipseg =
                                                                    g2.ctipseg
                                                        AND g.ccolect =
                                                                    g2.ccolect
                                                        AND g.cgarant =
                                                                    g2.cgarant);
                                       EXCEPTION
                                          WHEN OTHERS
                                          THEN
                                             gars (gars.LAST).icapital := 0;
                                       END;
                                    WHEN OTHERS
                                    THEN
                                       gars (gars.LAST).icapital := 0;
                                 END;
                              END IF;
                           /* fin Bug 21656 - APD - 12/06/2012*/
                           END IF;
                        /* Bug 26662 - APD  - 10/04/2013*/
                        END IF;
                     END IF;

                     /*Bug 26662 - APD - 10/04/2013 - se guarda el codigo de plan en el objeto*/
                     gars (gars.LAST).cplanbenef := vcplan;
                  /*fin Bug 26662 - APD - 10/04/2013*/
                  ELSE
                     /* Bug 26662 - APD - 15/04/2013 -- la garantia ya está cargada en el objeto*/
                     nerr := 0;

                     /* te canvis*/
                     IF vcplan IS NOT NULL
                     THEN
                        /* se debe mirar si la garantia pertenece al plan de beneficio*/
                        IF pac_planbenef.f_garant_planbenef
                                                         (det_poliza.cempres,
                                                          vcplan,
                                                          1,
                                                          gars (vnpos).cgarant
                                                         ) = 1
                        THEN
                           gars (vnpos).ctipgar := 2;
                           /* 2 obligatoria*/
                           gars (vnpos).cobliga := 1;
                        /* Bug 27652/149200 - APD - 16/07/2013*/
                        ELSE
                           gars (vnpos).ctipgar := garp (vgar).ctipgar;
                        /* fin Bug 27652/149200 - APD - 16/07/2013*/
                        END IF;

                        /* se debe mirar si existe valor de capital para la garantia*/
                        IF     garp (vgar).ctipcap = 7
                           AND (NVL (gars (vnpos).cplanbenef, 0) <> vcplan)
                        THEN
                           vicapital :=
                              pac_planbenef.f_capital_planbenef
                                                         (det_poliza.cempres,
                                                          vcplan,
                                                          2,
                                                          gars (vnpos).cgarant
                                                         );

                           IF vicapital IS NOT NULL
                           THEN
                              gars (vnpos).icapital := vicapital;
                           END IF;
                        END IF;
                     ELSE
                        gars (vnpos).ctipgar := garp (vgar).ctipgar;
                     END IF;

                     IF gars (vnpos).ctipgar = 2
                     THEN
                        /*svj*/
                        /* 2 obligatoria*/
                        gars (vnpos).cobliga := 1;
                     END IF;

                     -- INI IAXIS-5105 CJMR 22/08/2019
                     IF garp (vnpos).ctipgar = 4
                     THEN
                        gars (vnpos).cobliga :=
                                         padre_marcado (garp (vnpos).cgarant);
                     END IF;

                     -- FIN IAXIS-5105 CJMR 22/08/2019

                     -- INI CJMR IAXIS-4205 10/08/2019
                     --IF garp (vnpos).ctipgar = 4 THEN IAXIS-5105 CJMR 22/08/2019
                     --   gars (vnpos).cobliga := padre_marcado (garp (vnpos).cgarant);  IAXIS-5105 CJMR 22/08/2019
                     IF     gars (vnpos).cobliga = 1
                        AND (garp (vnpos).ctipgar IN (1, 2, 3, 4))
                     THEN                        -- IAXIS-5222 CJMR 24/09/2019
                        gars (vnpos).excontractual :=
                           NVL
                              (pac_iaxpar_productos.f_get_pargarantia
                                                   ('EXCONTRACTUAL',
                                                    det_poliza.sproduc,
                                                    gars (vnpos).cgarant,
                                                    det_poliza.gestion.cactivi
                                                   ),
                               0
                              );

                        --
                        IF gars (vnpos).excontractual = 0
                        THEN
                           --
                           --gars(vnpos).finivig := det_poliza.gestion.fefecto;
                           --gars(vnpos).ffinvig := det_poliza.gestion.fvencim;
                           gars (vnpos).finivig :=
                              NVL (gars (vnpos).finivig,
                                   det_poliza.gestion.fefecto
                                  );
                           gars (vnpos).ffinvig :=
                              NVL (gars (vnpos).ffinvig,
                                   det_poliza.gestion.fvencim
                                  );
                        --
                        ELSIF gars (vnpos).excontractual = 1
                        THEN
                           --
                           vnmeses :=
                              NVL
                                 (pac_iaxpar_productos.f_get_pargarantia
                                                   ('TIEMPO_POSTCONTR_LEY',
                                                    det_poliza.sproduc,
                                                    garp (vgar).cgarant,
                                                    det_poliza.gestion.cactivi
                                                   ),
                                  0
                                 );          -- INI IAXIS-5222 CJMR 04/09/2019
                           --gars(vnpos).finivig := det_poliza.gestion.fefecto;
                           --gars(vnpos).ffinvig := ADD_MONTHS(det_poliza.gestion.fvencplazo, vnmeses);--CASE WHEN (vnmeses = 0) THEN det_poliza.gestion.fvencplazo ELSE gars(vnpos).ffinvig END;
                           gars (vnpos).finivig :=
                              NVL (gars (vnpos).finivig,
                                   det_poliza.gestion.fefecto
                                  );
                           gars (vnpos).ffinvig :=
                              NVL (gars (vnpos).ffinvig,
                                   ADD_MONTHS (det_poliza.gestion.fvencplazo,
                                               vnmeses
                                              )
                                  );
                           -- INI IAXIS-5222 CJMR 04/09/2019
                        --
                        ELSE
                           --gars(vnpos).finivig := det_poliza.gestion.fvencplazo;
                           --gars(vnpos).ffinvig := det_poliza.gestion.fvencim;
                           gars (vnpos).finivig :=
                              NVL (gars (vnpos).finivig,
                                   det_poliza.gestion.fvencplazo
                                  );
                           gars (vnpos).ffinvig :=
                              NVL (gars (vnpos).ffinvig,
                                   det_poliza.gestion.fvencim
                                  );
                        --
                        END IF;
                     END IF;

                     --   END IF;  IAXIS-5105 CJMR 22/08/2019
                     -- FIN CJMR IAXIS-4205 10/08/2019
                     BEGIN
                        SELECT cmodalidad
                          INTO vresultado
                          FROM estriesgos
                         WHERE sseguro = det_poliza.sseguro
                           AND nriesgo = pnriesgo;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           vresultado := NULL;
                     END;

                     FOR j IN
                        det_poliza.riesgos.FIRST .. det_poliza.riesgos.LAST
                     LOOP
                        IF (    det_poliza.riesgos (j).nriesgo = pnriesgo
                            AND det_poliza.nmovimi = pnmovimi
                           )
                        THEN
                           IF NVL (vresultado, -9) !=
                                   NVL (det_poliza.riesgos (j).cmodalidad,
                                        -1)
                           THEN
                              /* Solo ponems el capital por defecto si ha cambidao la modalidad. En el type tenemos la modalidad actual en las tablas el anterior*/
                              IF garp (vgar).icapdef IS NOT NULL
                              THEN
                                 p_tab_error
                                    (f_sysdate,
                                     f_user,
                                     'PAC_MD_PRODUCCION.p_set_garanprod',
                                     NULL,
                                        ' --> Capital por defecto  ya existe '
                                     || ' pnriesgo  = '
                                     || pnriesgo
                                     || 'cgarant = '
                                     || garp (vgar).cgarant
                                     || ' icapdef '
                                     || garp (vgar).icapdef
                                     || ' cmodalidad type  = '
                                     || det_poliza.riesgos (1).cmodalidad
                                     || ' cmodalidad est = '
                                     || vresultado,
                                     SQLERRM
                                    );
                                 gars (vnpos).icapital := garp (vgar).icapdef;
                              ELSIF garp (vgar).ccapdef IS NOT NULL
                              THEN
                                 SELECT sgt_sesiones.NEXTVAL
                                   INTO xxsesion
                                   FROM DUAL;

                                 nerr :=
                                    pac_calculo_formulas.calc_formul
                                               (det_poliza.gestion.fefecto,
                                                det_poliza.sproduc,
                                                det_poliza.riesgos (j).cactivi,
                                                garp (vgar).cgarant,
                                                pnriesgo,
                                                det_poliza.sseguro,
                                                garp (vgar).ccapdef,
                                                vresultado,
                                                pnmovimi,
                                                xxsesion,
                                                1,
                                                det_poliza.gestion.fefecto,
                                                'R',
                                                NULL,
                                                1
                                               );

                                 IF vresultado IS NOT NULL
                                 THEN
                                    gars (vnpos).icapital := vresultado;
                                 END IF;
                              END IF;
                           END IF;

                           EXIT;
                        END IF;
                     END LOOP;

                     IF     NVL (f_parproductos_v (det_poliza.sproduc,
                                                   'ADMITE_CERTIFICADOS'
                                                  ),
                                 0
                                ) = 1
                        AND NOT pac_iax_produccion.isaltacol
                     THEN
                        /*AND pac_seguros.f_get_escertifcero(det_poliza.npoliza) = 0 THEN*/
                        vresp_9094 :=
                           f_get_obligaopcional_cero (det_poliza.npoliza,
                                                      vplancol,
                                                      garp (vgar).cgarant,
                                                      mensajes
                                                     );

                        /*Si la garantia tiene el ctipgar = 1 (opcional) y en la pregunta 9094 se ha contestado 1 -Obligatoria*/
                        /*la ponemos obligatoria y que se muestre chekeada.*/
                        IF     garp (vgar).ctipgar = 1
                           AND vresp_9094 = 1
                           AND NVL
                                  (pac_parametros.f_pargaranpro_n
                                                  (det_poliza.sproduc,
                                                   det_poliza.gestion.cactivi,
                                                   garp (vgar).cgarant,
                                                   'EXCEPCION_HEREDAGAR'
                                                  ),
                                   0
                                  ) = 0
                        THEN
                           gars (vnpos).ctipgar := 2;
                           gars (vnpos).cobliga := 1;
                        END IF;

                        /*Si la garantia tiene el ctipgar = 3 (Dependiente opcional) y en la pregunta 9094 se ha contestado 1 -Obligatoria*/
                        /*la ponemos obligatoria*/
                        IF garp (vgar).ctipgar = 3 AND vresp_9094 = 1
                        THEN
                           gars (vnpos).ctipgar := 4;
                        /*gars(gars.LAST).cobliga := 1;*/
                        END IF;

                        /*Si la garantia tiene el ctipgar = 5 (Dependiente opcional multiple) y en la pregunta 9094 se ha contestado 1 -Obligatoria*/
                        /*la ponemos obligatoria*/
                        IF garp (vgar).ctipgar = 5 AND vresp_9094 = 1
                        THEN
                           gars (vnpos).ctipgar := 6;
                        /*gars(gars.LAST).cobliga := 1;*/
                        END IF;

                        IF garp (vgar).ctipgar = 4
                        THEN
                           vnpos2 := existgar (garp (vgar).cgardep);

                           IF gars (vnpos2).cobliga = 1
                           THEN
                              gars (vnpos).cobliga := 1;
                           END IF;
                        END IF;
                     END IF;

                     /* exista o no plan, se guarda el codigo del plan de beneficio en el objeto*/
                     gars (vnpos).cplanbenef := vcplan;

                     /*fin Bug 26662 - APD - 10/04/2013*/
                     -- INI BUG CONF-1243 QT_1354 - 08/02/2018 - JLTS
                     IF pac_iax_produccion.issuplem
                     THEN
-- BUG CONF-1292_QT_1914 - 22/02/2018 - JLTS - Se adiciona para que no falle en Alta
                        IF gars (vnpos).cobliga = 1
                        THEN
                           IF gars (vnpos).excontractual IN (0)
                           THEN
                              gars (vnpos).finivig :=
                                 NVL
                                    (pac_iax_suplementos.lstmotmov (1).finiefe,
                                     gars (vnpos).finivig
                                    );            --IAXIS-3368 CJMR 04/04/2019
                              gars (vnpos).ffinvig :=
                                 NVL
                                    (pac_iax_suplementos.lstmotmov (1).fvencim,
                                     gars (vnpos).ffinvig
                                    );            --IAXIS-3368 CJMR 04/04/2019
                           ELSIF gars (vnpos).excontractual IN (1)
                           THEN
                              gars (vnpos).finivig :=
                                 NVL
                                    (pac_iax_suplementos.lstmotmov (1).finiefe,
                                     gars (vnpos).finivig
                                    );            --IAXIS-3368 CJMR 04/04/2019
                              gars (vnpos).ffinvig :=
                                 NVL
                                    (pac_iax_suplementos.lstmotmov (1).fvencplazo,
                                     gars (vnpos).ffinvig
                                    );            --IAXIS-3368 CJMR 04/04/2019
                           ELSIF gars (vnpos).excontractual IN (2)
                           THEN
                              gars (vnpos).finivig :=
                                 NVL
                                    (pac_iax_suplementos.lstmotmov (1).fvencplazo,
                                     gars (vnpos).finivig
                                    );            --IAXIS-3368 CJMR 04/04/2019
                              gars (vnpos).ffinvig :=
                                 NVL
                                    (pac_iax_suplementos.lstmotmov (1).fvencim,
                                     gars (vnpos).ffinvig
                                    );            --IAXIS-3368 CJMR 04/04/2019
                           END IF;
                        END IF;
                     END IF;      -- BUG CONF-1292_QT_1914 - 22/02/2018 - JLTS
                  -- FIN BUG CONF-1243 QT_1354 - 08/02/2018 - JLTS
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      /* Bug 21786 - APD - 30/03/2012 - se añade el IF*/
      /* solo se debe ejecutar la primera vez que se está cargando el objeto*/
      /* garantias, es decir, si v_cont = 0*/
      IF v_cont = 0
      THEN
         /* BUG8947:DRA:14/07/2009:Inici: Para ctipgar 4 hay que mirar si el padre está marcado*/
         IF gars IS NOT NULL
         THEN
            vpasexec := 21;

            IF gars.COUNT > 0
            THEN
               vpasexec := 22;

               FOR vgar IN gars.FIRST .. gars.LAST
               LOOP
                  vpasexec := 23;

                  IF gars.EXISTS (vgar)
                  THEN
                     vpasexec := 24;

                     /* Bug 17341 - RSC - 02/02/2011 - APR703 - Suplemento de preguntas - FlexiLife*/
                     IF garp.EXISTS (vgar)
                     THEN
                        /* Fin Bug 17341*/
                        IF garp (vgar).ctipgar = 4
                        THEN
                           gars (vgar).cobliga :=
                                          padre_marcado (garp (vgar).cgarant);

                           /* Bug 21786 - APD - 30/03/2012*/
                           IF gars (vgar).cobliga = 1
                           THEN
                              IF garp (vgar).ctipcap = 1
                              THEN
                                 /* indica que el capital es fitxe i sha de mostrar el valor del capital*/
                                 gars (vgar).icapital := garp (vgar).icapmax;
                              /* Ini Bug 21707 - 20/03/2012 - MDS*/
                              ELSIF garp (vgar).ctipcap = 2
                              THEN
                                 gars (vgar).icapital :=
                                    pac_parametros.f_pargaranpro_n
                                                 (det_poliza.sproduc,
                                                  det_poliza.gestion.cactivi,
                                                  gars (vgar).cgarant,
                                                  'VALORDEFCAPITALGARAN'
                                                 );
                              /* fin Bug 21707 - 20/03/2012 - MDS*/
                              END IF;
                           END IF;
                        /* fin Bug 21786 - APD - 30/03/2012*/
                        END IF;
                     /* Bug 17341 - RSC - 02/02/2011 - APR703 - Suplemento de preguntas - FlexiLife*/
                     END IF;
                  /* Fin Bug 17341*/
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      /* fin Bug 21786 - APD - 30/03/2012*/
      /* BUG8947:DRA:14/07/2009:Fi*/
      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 2;
            RETURN 1;
         END IF;
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END p_set_garanprod;

   -- INI BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
   /***********************************************************************
   Busca el fefecto de la póliza (garantias)
   param in detPoliza    : objeto detalle poliza
   param in gest         : objeto gestión
   param in out mensajes : mensajes error
   return                : 0 todo correcto
   1 ha habido un error
   ***********************************************************************/
   FUNCTION f_get_finiefe (
      psseguro   IN       seguros.sseguro%TYPE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN DATE
   IS
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (1)   := NULL;
      vobject     VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_get_fefecto';
      nerr        NUMBER;
      v_finiefe   DATE           := TO_DATE (NULL);
   BEGIN
      BEGIN
         SELECT MAX (e.finiefe)
           INTO v_finiefe
           FROM estgaranseg e
          WHERE e.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            nerr := SQLCODE;
      END;

      RETURN v_finiefe;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN v_finiefe;
   END f_get_finiefe;

   -- FIN BUG CONF-1243 QT_724
   /***********************************************************************
   Busca el cobrador bancario
   param in detPoliza    : objeto detalle poliza
   param in gest         : objeto gestión
   param in out mensajes : mensajes error
   return                : 0 todo correcto
   1 ha habido un error
   ***********************************************************************/
   FUNCTION f_get_cobban (
      detpoliza   IN       ob_iax_detpoliza,
      gest        IN OUT   ob_iax_gestion,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Get_CobBan';
      nerr       NUMBER;
      RESULT     NUMBER;
   BEGIN
      RESULT :=
         f_buscacobban (detpoliza.cramo,
                        detpoliza.cmodali,
                        detpoliza.ctipseg,
                        detpoliza.ccolect,
                        detpoliza.cagente,
                        gest.cbancar,
                        NVL (gest.ctipban, 1),
                        nerr
                       );

      IF nerr > 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         gest.ccobban := NULL;
         RETURN 1;
      END IF;

      gest.ccobban := RESULT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_cobban;

   /*************************************************************************
      Recupera las cuentas corrientes del primer tomador
      param in psperson  : código personas
      param in psseguro  : número seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tomadorccc (
      psperson   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes,
      psseguro   IN       NUMBER DEFAULT NULL,
      pmandato   IN       VARCHAR2 DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      vumerr     NUMBER;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.F_Get_TomadorCCC';
      squery     VARCHAR2 (3000);
      cur        sys_refcursor;
   BEGIN
      IF pac_iax_produccion.vpmode = 'POL'
      THEN
         /* Bug 5912*/
         /* Bug 20683 - APD - 13/01/2011 - se añade el campo cdefecto y el order by cdefecto desc*/
         squery :=
               'SELECT sperson, cbancar, Tcbancar, ctipban, snip, cbancar_1, cdefecto FROM ( '
            || 'SELECT PER.SPERSON, PER.CBANCAR,'
            || ' PAC_MD_COMMON.F_FormatCCC(PER.CTIPBAN,PER.CBANCAR) Tcbancar, PER.CTIPBAN,'
            || ' PS.SNIP,PER.CBANCAR cbancar_1, per.cdefecto cdefecto'
            || '  FROM CCC PER , PERSONAS PS'
            || '  WHERE PER.SPERSON = PS.SPERSON'
            || ' AND PER.SPERSON = '
            || psperson
            || '
                                AND PER.FBAJA IS NULL'
            || ' UNION'
            || ' SELECT t.SPERSON, s.CBANCAR,'
            || ' PAC_MD_COMMON.F_FormatCCC(s.CTIPBAN,s.CBANCAR) Tcbancar, s.CTIPBAN,'
            || ' PS.SNIP,s.CBANCAR cbancar_1,'
            || ' (select cdefecto from per_ccc p where p.sperson = PS.SPERSON and p.cbancar = s.cbancar and p.cagente = ps.cagente and p.ctipban = ps.ctipban) cdefecto '
            || ' FROM TOMADORES t , PERSONAS PS, SEGUROS s'
            || ' WHERE t.SPERSON = PS.SPERSON'
            || ' AND t.sseguro = s.sseguro'
            || ' AND s.sseguro = '
            || NVL (TO_CHAR (psseguro), ' NULL')
            || ' ) sel ';
      /* Bug 20683 - APD - 13/01/2011 - fin*/
      ELSE
         /* Bug 20683 - APD - 13/01/2011 - se añade el campo cdefecto y el order by cdefecto desc*/
         squery :=
               'SELECT sperson, cbancar, Tcbancar, ctipban, snip, cbancar_1, cdefecto FROM  ( '
            || 'SELECT PER.SPERSON, PER.CBANCAR, '
            || ' PAC_MD_COMMON.F_FormatCCC(PER.CTIPBAN,PER.CBANCAR) Tcbancar, PER.CTIPBAN, PS.SNIP,PER.CBANCAR cbancar_1, per.cdefecto cdefecto'
            || ' FROM estper_ccc PER ,estper_personas PS WHERE PER.SPERSON = PS.SPERSON AND PER.SPERSON = '
            || psperson
            || '   AND PER.FBAJA IS NULL UNION  SELECT t.SPERSON, est.CBANCAR, PAC_MD_COMMON.F_FormatCCC(est.CTIPBAN,est.CBANCAR) Tcbancar, est.CTIPBAN, PS.SNIP,est.CBANCAR cbancar_1,'
            || '  (select cdefecto  from estper_ccc p where p.sperson = PS.SPERSON and p.cbancar = est.CBANCAR and p.cagente = ps.cagente and p.ctipban = ps.ctipban) cdefecto'
            || '  FROM ESTTOMADORES t , estpersonas PS, ESTSEGUROS EST WHERE t.SPERSON = PS.SPERSON AND t.sseguro = est.sseguro      AND est.cbancar IS NOT NULL AND est.cbancar NOT IN(SELECT per.cbancar FROM estccc per WHERE   PER.FBAJA IS  NULL and per.sperson ='
            || psperson
            || ') '
            || '  AND est.sseguro = '
            || NVL (TO_CHAR (psseguro), ' NULL')
            || ' ) sel ';
      /* Bug 20683 - APD - 13/01/2011 - fin*/
      END IF;

      /* RSA MANDATOS*/
      IF NVL (pmandato, 'N') = 'S'
      THEN
         IF pac_iax_produccion.vpmode = 'POL'
         THEN
            squery :=
                  squery
               || ' WHERE EXISTS (SELECT 1 from  MANDATOS MA
                                          WHERE MA.CBANCAR = sel.cbancar
                                          AND MA.SPERSON = sel.sperson
                                          AND  ma.cestado IN (0,1))';
         ELSE
            squery :=
                  squery
               || ' WHERE EXISTS (SELECT 1 from  ESTMANDATOS MA
                                          WHERE MA.CBANCAR = sel.cbancar
                                          AND MA.SPERSON = sel.sperson
                                          AND  ma.cestado IN (0,1))';
         END IF;
      END IF;

      squery := squery || ' ORDER BY CDEFECTO DESC';
      vumerr :=
         pac_log.f_log_consultas (squery,
                                  'PAC_MD_PRODUCCION.F_GET_TOMADORCCC',
                                  1
                                 );
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tomadorccc;

   /*************************************************************************
      Prepara las tablas de rentas previamente a tarificar.
      Solución Temporal. Cuando sea simulación se deberá en algún caso poner ICAPREN a nul si lo que informan por pantalla es la renta.
      param in pmode     : modo de tarificación
      param in psolicit  : código de solicitud
   *************************************************************************/
   PROCEDURE p_preparar_tarif (
      pmode      IN       VARCHAR2,
      psolicit   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
   IS
      vcapinirent   estseguros_ren.icapren%TYPE;
      vibruren      estseguros_ren.ibruren%TYPE;
      det_poliza    ob_iax_detpoliza;
   BEGIN
      /* Bug 10336 - 20/09/2009- JRH - CRE - Simular producto de rentas a partir del importe de renta y no de la prima*/
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        32332,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_object_error;
      END IF;

      IF NVL (f_parproductos_v (det_poliza.sproduc, 'ES_PRODUCTO_RENTAS'), 0) =
                                                                             1
      THEN
         /*JRH Miramos si está la aportación informada o la renta*/
         vibruren :=
            NVL (pac_calc_comu.ff_capital_gar_tipo (pmode, psolicit, 1, 8, 1),
                 0
                );
         /*    IF vibruren <> 0 THEN
         vcapinirent := 0;
          END IF;*/
         vcapinirent :=
            NVL (pac_calc_comu.ff_capital_gar_tipo (pmode, psolicit, 1, 3, 1),
                 0
                );

         /*     IF vcapinirent <> 0 THEN
         vibruren := 0;
           END IF;*/
         IF pmode = 'EST'
         THEN
            UPDATE estseguros_ren
               SET ibruren = NVL (vibruren, 0),
                   icapren = NVL (vcapinirent, 0)
             WHERE sseguro = psolicit;

            UPDATE estgaranseg
               /* JRH Obligamos a que se contrate la aportación inicial*/
            SET cobliga = 1
             WHERE sseguro = psolicit
               AND NVL
                      (pac_iaxpar_productos.f_get_pargarantia
                                                   ('TIPO',
                                                    det_poliza.sproduc,
                                                    estgaranseg.cgarant,
                                                    det_poliza.gestion.cactivi
                                                   ),
                       /* BUG 0036730 - FAL - 09/12/2015*/
                       0
                      ) IN (3, 8, 9);
         ELSIF pmode = 'SOL'
         THEN
            UPDATE solseguros_ren
               SET ibruren = DECODE (vibruren, 0, 0, vibruren),
                   icapren = NVL (icapren, 0)
             WHERE ssolicit = psolicit;

            UPDATE solgaranseg
               /* JRH Obligamos a que se contrate la aportación inicial*/
            SET cobliga = 1
             WHERE ssolicit = psolicit
               AND NVL
                      (pac_iaxpar_productos.f_get_pargarantia
                                                   ('TIPO',
                                                    det_poliza.sproduc,
                                                    solgaranseg.cgarant,
                                                    det_poliza.gestion.cactivi
                                                   ),
                       /* BUG 0036730 - FAL - 09/12/2015*/
                       0
                      ) IN (3, 8, 9);
         END IF;
      END IF;
   /* fi Bug 10336 - 20/09/2009- JRH*/
   END;

   /*************************************************************************
      Tarifica el riesgo
      param in pmode     : modo de tarificación
      param in psolicit  : código de solicitud
      param in pnriesgo  : número de riesgo
      param in pnmovimi  : número de movimiento
      param in pfefecto  : fecha efecto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error o codigo error
   *************************************************************************/
   FUNCTION f_tarifar_riesgo_tot (
      pmode      IN       VARCHAR2,
      psolicit   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)               := 1;
      vparam     VARCHAR2 (1)             := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_MD_PRODUCCION.F_Tarifar_Riesgo_Tot';
      nerror     NUMBER;
      /* JLB - I - BUG 18423 COjo la moneda del producto*/
      vcmoneda   monedas.cmoneda%TYPE;
      /* JLB - F- BUG 18423 COjo la moneda del producto*/
      vmodo      VARCHAR2 (2);                             /* JRH Convenios*/
      vcmovseg   movseguro.cmovseg%TYPE;                   /* JRH Convenios*/
   BEGIN
      p_preparar_tarif (pmode, psolicit, mensajes);

      /* JLB - I - BUG 18423 COjo la moneda del producto*/
      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc)
           INTO vcmoneda
           FROM estseguros
          WHERE sseguro = psolicit;
      EXCEPTION
         WHEN OTHERS
         THEN
            vcmoneda := f_parinstalacion_n ('MONEDAINST');
      END;

      /*Convenios*/
      vmodo := 'NP';
      vpasexec := 10;

      IF pac_iax_produccion.issuplem
      THEN
         IF pac_iax_suplementos.lstmotmov IS NOT NULL
         THEN
            vpasexec := 11;

            IF pac_iax_suplementos.lstmotmov.COUNT = 1
            THEN
               vpasexec := 12;

               IF pac_iax_suplementos.lstmotmov.EXISTS (1)
               THEN
                  vpasexec := 14;

                  SELECT cmovseg
                    INTO vcmovseg
                    FROM codimotmov
                   WHERE cmotmov = pac_iax_suplementos.lstmotmov (1).cmotmov;

                  vpasexec := 15;

                  IF vcmovseg = 6
                  THEN
                     vmodo := 'RG';
-- Si estamos en regularización (suplemento incompatible con todos los demas, sólo hay 1 suplemento) enviamos el aviso de ello al pac_tarifas.
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      /*Convenios*/
      /* JLB - F- BUG 18423 COjo la moneda del producto*/
      /* Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima*/
      IF pac_iax_produccion.imodifgar
      THEN
         /* Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas*/
         IF pac_md_produccion.f_bloqueo_grabarobjectodb
                                   (pac_iax_produccion.vsseguro,
                                    pac_iax_suplementos.lstmotmov (1).cmotmov,
                                    mensajes
                                   ) = 1
         THEN
            nerror :=
               pac_tarifas.f_tarifar_riesgo_tot (pmode,
                                                 psolicit,
                                                 pnriesgo,
                                                 pnmovimi,
                                                 /* JLB - I - BUG 18423 COjo la moneda del producto*/
                                                 /* f_parinstalacion_n('MONEDAINST'),*/
                                                 vcmoneda,
                                                 /* JLB - F- BUG 18423 COjo la moneda del producto*/
                                                 pfefecto,
                                                 'APO',
                                                 'EXTRA'
                                                );
         ELSE
            /* Fin Bug 13832*/
            nerror :=
               pac_tarifas.f_tarifar_riesgo_tot (pmode,
                                                 psolicit,
                                                 pnriesgo,
                                                 pnmovimi,
                                                 /* JLB - I - BUG 18423 COjo la moneda del producto*/
                                                 /* f_parinstalacion_n('MONEDAINST'),*/
                                                 vcmoneda,
                                                 /* JLB - F - BUG 18423 COjo la moneda del producto*/
                                                 pfefecto,
                                                 'NP',
                                                 'MODIF'
                                                );
         END IF;
      /* Bug 11735 - RSC - 11/05/2010 - APR - suplemento de modificación de capital /prima*/
      ELSIF pac_iax_produccion.isaltagar OR pac_iax_produccion.isbajagar
      THEN
         nerror :=
            pac_tarifas.f_tarifar_riesgo_tot (pmode,
                                              psolicit,
                                              pnriesgo,
                                              pnmovimi,
                                              /* JLB - I - BUG 18423 COjo la moneda del producto*/
                                              /*f_parinstalacion_n('MONEDAINST'),*/
                                              vcmoneda,
                                              /* JLB - F- BUG 18423 COjo la moneda del producto*/
                                              pfefecto,
                                              'NP',
                                              'ALTA'
                                             );
      ELSE
         /* Fin Bug 11735*/
         /* BUG 17341 - 24/01/2011 - JMP - Tratamos como caso especial los productos con detalle de garantÃ­as (APRA)*/
         IF NVL
               (f_parproductos_v
                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                 'DETALLE_GARANT'
                                ),
                0
               ) IN (1, 2)
         THEN
            IF pac_iax_produccion.issuplem
            THEN
               IF pac_md_produccion.f_grabargar_modifdb
                                   (pac_iax_produccion.vsseguro,
                                    pac_iax_suplementos.lstmotmov (1).cmotmov,
                                    mensajes
                                   ) = 1
               THEN
                  /* Volcamos a BDD la información introducida por pantalla*/
                  nerror :=
                     pac_md_grabardatos.f_grabarriesgos
                               (pac_iax_produccion.poliza.det_poliza.riesgos,
                                mensajes
                               );

                  IF nerror = 1
                  THEN
                     vpasexec := 8;
                     RAISE e_object_error;
                  END IF;

                  FOR regs IN
                     (SELECT g.nriesgo, g.cgarant
                        FROM estgaranseg g, estseguros s
                       WHERE g.sseguro = psolicit
                         AND g.nmovimi = pnmovimi
                         AND s.sseguro = g.sseguro
                         AND NVL (f_pargaranpro_v (s.cramo,
                                                   s.cmodali,
                                                   s.ctipseg,
                                                   s.ccolect,
                                                   s.cactivi,
                                                   g.cgarant,
                                                   UPPER ('TIPO')
                                                  ),
                                  0
                                 ) NOT IN (4, 5)
                         AND g.cobliga = 1)
                  LOOP
                     /* Marcamos los detalles de cada garantÃ­a para indicar si se tarifan o no*/
                     pk_nueva_produccion.p_select_tarifar_detalle
                                                (pac_iax_produccion.vsseguro,
                                                 psolicit,
                                                 regs.nriesgo,
                                                 pnmovimi,
                                                 regs.cgarant
                                                );
                  END LOOP;

                  nerror :=
                     pac_tarifas.f_tarifar_riesgo_tot (pmode,
                                                       psolicit,
                                                       pnriesgo,
                                                       pnmovimi,
                                                       /* JLB - I - BUG 18423 COjo la moneda del producto*/
                                                       /* f_parinstalacion_n('MONEDAINST'),*/
                                                       vcmoneda,
                                                       /* JLB - F - BUG 18423 COjo la moneda del producto*/
                                                       pfefecto,
                                                       'NP',
                                                       'MODIF'
                                                      );
               END IF;
            ELSE
               nerror :=
                  pac_tarifas.f_tarifar_riesgo_tot (pmode,
                                                    psolicit,
                                                    pnriesgo,
                                                    pnmovimi,
                                                    /* JLB - I - BUG 18423 COjo la moneda del producto*/
                                                    /* f_parinstalacion_n('MONEDAINST'),*/
                                                    vcmoneda,
                                                    /* JLB - F - BUG 18423 COjo la moneda del producto*/
                                                    pfefecto
                                                   );
            END IF;
         ELSE
            /* FIN BUG 17341 - 24/01/2011 - JMP*/
            nerror :=
               pac_tarifas.f_tarifar_riesgo_tot (pmode,
                                                 psolicit,
                                                 pnriesgo,
                                                 pnmovimi,
                                                 /* JLB - I - BUG 18423 COjo la moneda del producto*/
                                                 /* f_parinstalacion_n('MONEDAINST'),*/
                                                 vcmoneda,
                                                 /* JLB - F - BUG 18423 COjo la moneda del producto*/
                                                 pfefecto,
                                                 vmodo
                                                );
         END IF;
      END IF;

      RETURN nerror;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_tarifar_riesgo_tot;

   /*************************************************************************
      Traspasamos los registros de las tablas EST a las REALES
      param in psolicit     : número solicitud
      param in pfefecto  : fecha efecto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error o codigo error
   *************************************************************************/
   FUNCTION traspaso_tablas_est (
      psolicit   IN       NUMBER,
      pfefecto   IN       DATE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)       := 1;
      vparam        VARCHAR2 (1)     := NULL;
      vobject       VARCHAR2 (200)
                                 := 'PAC_MD_PRODUCCION.F_Traspaso_Tablas_Est';
      nerror        NUMBER;
      vmens         VARCHAR2 (1000);
      vprimatotal   NUMBER;
      vssegpol      NUMBER;
      v_nmovimi     NUMBER;                       /* BUG9718:DRA:23/04/2009*/
      detpoliza2    ob_iax_detpoliza;       /* Bug 21924 - MDS - 20/06/2012*/
   BEGIN
      /* BUG9718:DRA:23/04/2009:Inici*/
      vpasexec := 1;
      v_nmovimi := 1;
      nerror :=
          pac_clausulas.f_ins_clausulas (psolicit, NULL, v_nmovimi, pfefecto);

      IF nerror <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      /* BUG9718:DRA:23/04/2009:Fi*/
      /* Bug 21924 - MDS - 20/06/2012*/
      /* tercer parámetro : detpoliza2.gestion.cdomper*/
      detpoliza2 := pac_iobj_prod.f_getpoliza (mensajes);
      pac_alctr126.traspaso_tablas_est (psolicit,
                                        pfefecto,
                                        detpoliza2.gestion.cdomper,
                                        vmens,
                                        'ALCTR126',
                                        NULL,
                                        v_nmovimi,
                                        NULL
                                       );

      IF vmens IS NOT NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 105419, vmens);
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      SELECT ssegpol
        INTO vssegpol
        FROM estseguros
       WHERE sseguro = psolicit;

      vprimatotal := f_segprima (vssegpol, pfefecto);

      UPDATE seguros
         SET iprianu = vprimatotal
       WHERE sseguro = vssegpol;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END traspaso_tablas_est;

   /*************************************************************************
      Emite la propuesta
      param in psolicit  : número solicitud
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error o codigo error
   *************************************************************************/
   FUNCTION f_emitir_propuesta (
      psolicit    IN       NUMBER,
      onpoliza    OUT      NUMBER,
      osseguro    OUT      NUMBER,
      onmovimi    OUT      NUMBER,
      mensajes    IN OUT   t_iax_mensajes,
      pcommit              NUMBER DEFAULT 1,
      /* Bug 26070 --ECP -- 21/02/2013*/
      pvsseguro   IN       NUMBER
            DEFAULT NULL                 -- Ini IAXIS-3504 --ECP -- 03/02/2010
   )
      RETURN NUMBER
   IS
      v_usuario       VARCHAR2 (100);
      v_usu_context   VARCHAR2 (100);
      vvsseguro       NUMBER;
      vcempres        NUMBER;
      vnpoliza        NUMBER;
      vncertif        NUMBER;
      vcramo          NUMBER;
      vcmodali        NUMBER;
      vctipseg        NUMBER;
      vccolect        NUMBER;
      vcactivi        NUMBER;
      vcidioma        NUMBER;
      vtmsg           VARCHAR2 (500);
      indice          NUMBER (8);
      indice_e        NUMBER (8);
      v_cmotret       NUMBER (8);
      vnumerr         NUMBER (8)     := 0;
      vpasexec        NUMBER (8)     := 1;
      vparam          VARCHAR2 (200)
         :=    'psolicit: '
            || psolicit
            || ' - osseguro: '
            || osseguro
            || ' -pvsseguro: '
            || pvsseguro
            || ' - onmovimi: '
            || onmovimi
            || ' - onpoliza: '
            || onpoliza;
      vobject         VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Emitir_Propuesta';
      v_fcancel       DATE;
      vcreteni        NUMBER;
      vsproduc        NUMBER;
      vnmovimi        NUMBER;
      /* Bug 20672 - RSC - 19/02/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
      v_nsolici       NUMBER;
      v_npoliza       NUMBER;
      v_sncertif      VARCHAR2 (9);
      v_ncertif       NUMBER;
      wsperson        NUMBER;
      v_femisio       DATE;
      v_fdiligencia   DATE;
      wspereal        NUMBER;
      vapuntereturn   NUMBER;
      v_hayapunte     NUMBER;
      vidapunte_out   NUMBER;
      /* Fin bug 20672*/
      /* BUG 27642 - FAL - 24/04/2014*/
      pmensaje        VARCHAR2 (500);
      /* v_existe       NUMBER;*/
      /* n_nmotret      NUMBER;*/
      /* FI BUG 27642*/
         --
         -- Inicio IAXIS-7650 20/11/2019
         --
      rie             ob_iax_riesgos;
      pri             ob_iax_primas;
   --
   -- Fin IAXIS-7650 20/11/2019
   --
   BEGIN
      vpasexec := 1;

      /*Obtenemos el sseguro de las tablas REALES.*/
      BEGIN
         SELECT ssegpol
           INTO vvsseguro
           FROM estseguros
          WHERE sseguro = psolicit;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF pac_iax_produccion.issuplem = TRUE
            THEN
               vvsseguro := pac_iax_produccion.vsseguro;
            ELSE
               --INi IAXIS -3504 -- ECP --03/02/2020
               vvsseguro := pvsseguro;

               IF vvsseguro IS NULL
               THEN
                  RAISE e_object_error;
               END IF;
            --Fin IAXIS -3504 -- ECP --03/02/2020
            END IF;
      END;

      vpasexec := 3;

      /*Obtenemos los datos de las tablas REALES necesarios para emitir.*/
      BEGIN
         SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg,
                ccolect, cactivi, cidioma
                                         /* JLB - I - BUG 18423 COjo la moneda del producto*/
         ,      sproduc
           /* JLB - F - BUG 18423*/
         INTO   vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg,
                vccolect, vcactivi, vcidioma
                                            /* JLB - I - BUG 18423 COjo la moneda del producto*/
         ,      vsproduc
           /* JLB - F - BUG 18423*/
         FROM   seguros
          WHERE sseguro = vvsseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT cempres, npoliza, ncertif, cramo, cmodali,
                      ctipseg, ccolect, cactivi, cidioma
                                                        /* JLB - I - BUG 18423 COjo la moneda del producto*/
               ,      sproduc
                 /* JLB - F - BUG 18423*/
               INTO   vcempres, vnpoliza, vncertif, vcramo, vcmodali,
                      vctipseg, vccolect, vcactivi, vcidioma
                                                            /* JLB - I - BUG 18423 COjo la moneda del producto*/
               ,      vsproduc
                 /* JLB - F - BUG 18423*/
               FROM   estseguros
                WHERE sseguro = psolicit;
            END;
      END;

      vpasexec := 5;

      /*Se valida apunte al usuario por sarlaf*/
      IF (NVL (pac_parametros.f_parproducto_n (vsproduc, 'ANTIGUEDAD_FCC'), 0) =
                                                                             1
         )
      THEN
         IF pac_iax_produccion.issuplem <> TRUE
         THEN
            BEGIN
               SELECT sperson
                 INTO wsperson
                 FROM esttomadores
                WHERE sseguro = psolicit AND nordtom = 1;
            END;

            vpasexec := 51;

            BEGIN
               SELECT spereal
                 INTO wspereal
                 FROM estper_personas
                WHERE sperson = wsperson;
            END;

            vpasexec := 52;

            BEGIN
               SELECT femisio
                 INTO v_femisio
                 FROM estseguros
                WHERE sseguro = psolicit;
            END;

            vpasexec := 53;

            BEGIN
               SELECT NVL (MAX (fdiligencia), v_femisio - 750)
                 INTO v_fdiligencia
                 FROM datsarlatf
                WHERE sperson = wspereal;
            END;
         ELSE
            BEGIN
               SELECT sperson
                 INTO wsperson
                 FROM tomadores
                WHERE sseguro = vvsseguro AND nordtom = 1;
            END;

            vpasexec := 511;

            BEGIN
               SELECT femisio
                 INTO v_femisio
                 FROM seguros
                WHERE sseguro = vvsseguro;
            END;

            vpasexec := 512;

            BEGIN
               SELECT NVL (MAX (fdiligencia), v_femisio - 750)
                 INTO v_fdiligencia
                 FROM datsarlatf
                WHERE sperson = wsperson;
            END;

            vpasexec := 513;
         END IF;

         vpasexec := 600;

         IF ((v_femisio - v_fdiligencia) > 700)
         THEN
            vapuntereturn :=
               pac_agenda.f_set_apunte (NULL,
                                        NULL,
                                        3,
                                        NULL,
                                        1,                             --Tarea
                                        0,
                                        NULL,
                                        NULL,
                                        f_axis_literales (9902423),
                                        f_axis_literales (89906093),
                                        0,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        vidapunte_out
                                       );
            vpasexec := 601;

            --
            SELECT COUNT (*)
              INTO v_hayapunte
              FROM agd_apunte a, agd_agenda b
             WHERE a.idapunte = b.idapunte
               AND a.ttitapu = f_axis_literales (9902423)
               AND a.ctipapu = 0
               AND b.tclagd = TO_CHAR (vvsseguro);

            vpasexec := 602;

            --
            IF v_hayapunte = 0
            THEN
               --
               vpasexec := 603;

               IF vapuntereturn = 0
               THEN
                  vpasexec := 604;
                  vapuntereturn :=
                     pac_agenda.f_set_agenda (vidapunte_out,
                                              NULL,
                                              f_user,
                                              0,
                                              '',
                                              1,
                                              vvsseguro,
                                              0,
                                              f_user,
                                              0,
                                              ''
                                             );
                  vpasexec := 605;
               END IF;
            --
            END IF;
         END IF;
      END IF;

      vpasexec := 7;
      /* dra 27-10-2008: bug mantis 7519*/
      /*Esborrem les taules temporals.*/
      pac_alctr126.borrar_tablas_est (psolicit);
      vnmovimi := pac_movseguro.f_nmovimi_ult (vvsseguro);

      /* Bug 20672 - RSC - 19/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
      /*
        En suplementos se hac?tradicionalmente roolback de todo de manera que si fallaba la emisi??or lo que sea
        no se gravaba el movimiento y se perdian las modificaciones. Se ha decidido crear este parametro para grabar
        el movimiento s? s?Si luego falla la emisi??odremos mirar de emitirlo despues.
      */
      IF NVL (pac_parametros.f_parempresa_n (vcempres, 'COMMIT_EN_SUPLEMENTO'),
              0
             ) = 1
      THEN
         IF pcommit = 1
         THEN
            /* Bug 26070 --ECP -- 21/02/2013*/
            COMMIT;
         END IF;
      ELSE
         /* Fin Bug 20672*/
         IF NVL (vnmovimi, 0) = 0
         THEN
            COMMIT;
         END IF;
      /* Bug 20672 - RSC - 19/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
      END IF;

      /* Fin Bug 20672*/
      vpasexec := 9;
      v_usuario := f_user;

      /* Bug 0016106 - RSC - 25/10/2010 - APR - Ajustes e implementación para el alta de colectivos*/
      IF pac_iax_produccion.isaltacol = FALSE
      THEN
         --
         -- Inicio IAXIS-7650 20/11/2019
         --
         IF pac_iax_produccion.poliza.det_poliza IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        1000644,
                                        'No se ha inicializado correctamente'
                                       );
            RAISE e_param_error;
         END IF;

         vpasexec := 10;
         rie :=
            pac_iobj_prod.f_partpolriesgo
                                        (pac_iax_produccion.poliza.det_poliza,
                                         1,
                                         mensajes
                                        );
         vpasexec := 11;

         IF rie IS NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes,
                                              1,
                                              1000646,
                                              'No se ha encontrado el riesgo'
                                             );
            RAISE e_object_error;
         END IF;

         --
         vpasexec := 12;
         --
         pri := rie.f_get_primas (vvsseguro, vnmovimi, 'SEG');
         --
         vpasexec := 13;
         --
         -- Fin IAXIS-7650 20/11/2019
         --
          /* Fin Bug 16106*/
         p_emitir_propuesta (vcempres,
                             vnpoliza,
                             vncertif,
                             vcramo,
                             vcmodali,
                             vctipseg,
                             vccolect,
                             vcactivi,
                             /* JLB - I - BUG 18423 COjo la moneda del producto*/
                             /*       1,*/
                             pac_monedas.f_moneda_producto (vsproduc),
                             /* JLB - f - BUG 18423 COjo la moneda del producto*/
                             vcidioma,
                             indice,
                             indice_e,
                             v_cmotret,
                             pmensaje,       /* BUG 27642 - FAL - 24/04/2014*/
                             NULL,
                             NULL,
                             1,
                             pri.itotdev              -- IAXIS-7650 20/11/2019
                            );
      /* Bug 0016106 - RSC - 25/10/2010 - APR - Ajustes e implementación para el alta de colectivos*/
      ELSE
         pac_seguros.p_emitir_propuesta_col
                                    (vcempres,
                                     vnpoliza,
                                     vncertif,
                                     vcramo,
                                     vcmodali,
                                     vctipseg,
                                     vccolect,
                                     vcactivi,
                                     /* JLB - I - BUG 18423 COjo la moneda del producto*/
                                     /*       1,*/
                                     pac_monedas.f_moneda_producto (vsproduc),
                                     /* JLB - f - BUG 18423 COjo la moneda del producto,*/
                                     vcidioma,
                                     indice,
                                     indice_e,
                                     v_cmotret,
                                     NULL,
                                     NULL,
                                     1
                                    );
      END IF;

      v_usu_context := f_parinstalacion_t ('CONTEXT_USER');
      pac_contexto.p_contextoasignaparametro (v_usu_context,
                                              'nombre',
                                              v_usuario
                                             );

      /* Fin Bug 16106*/
      SELECT npoliza, sseguro, NVL (creteni, 0), sproduc, ncertif
        INTO onpoliza, osseguro, vcreteni, vsproduc, v_ncertif
        FROM seguros
       WHERE sseguro = vvsseguro;

      /*// ACC 04052008 control la data cancelació proposta*/
      IF vcreteni = 1
      THEN
         vnumerr :=
                  pac_seguros.f_get_set_fcancel (vvsseguro, 'POL', v_fcancel);

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         COMMIT;
      END IF;

      /*// ACC 04052008*/
      onmovimi := pac_movseguro.f_nmovimi_ult (osseguro);

      IF NVL (onmovimi, 0) = 0
      THEN
         onmovimi := 1;
      END IF;

      /* BUG9640:DRA:22/04/2009:Inici*/
      /* Bug 20672 - RSC - 19/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
      IF    (NOT pac_iax_produccion.issuplem)
         OR (NVL (pac_parametros.f_parempresa_n (vcempres,
                                                 'COMMIT_EN_SUPLEMENTO'
                                                ),
                  0
                 ) = 1
            )
      THEN
         /* Fin bug 20672*/
         /* BUG 27642 - FAL - 24/04/2014*/
         IF pmensaje IS NOT NULL
         THEN
            v_cmotret := 53;
         END IF;

         /* FI BUG 27642*/
         vnumerr :=
            pac_emision_mv.f_texto_emision (osseguro,
                                            indice,
                                            indice_e,
                                            v_cmotret,
                                            pac_md_common.f_get_cxtidioma,
                                            vtmsg
                                           );

         /* BUG 27642 - FAL - 24/04/2014*/
         IF pmensaje IS NOT NULL
         THEN
            vtmsg := vtmsg || pmensaje;
         END IF;

         /* FI BUG 27642*/
         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      /* Bug 20672 - RSC - 19/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
      ELSE
         IF indice_e = 0 AND indice >= 1
         THEN
            IF pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                      vsproduc
                                                     ) = 1
            THEN
               v_sncertif := ' - ' || v_ncertif;
            ELSE
               v_sncertif := NULL;
            END IF;

            /*vtmsg := f_axis_literales(151301, pac_md_common.f_get_cxtidioma) || ' ' || onpoliza
            || v_sncertif;*/
            /* BUG 24722 AMJ 24/12/2012  Numero de Anexo en Impresion Ini*/
            IF NVL (pac_parametros.f_parempresa_n (vcempres, 'SHOW_MOV'), 0) =
                                                                             1
            THEN
               vtmsg :=
                     f_axis_literales (151301, pac_md_common.f_get_cxtidioma)
                  || ' '
                  || onpoliza
                  || v_sncertif
                  || '. '
                  || f_axis_literales (9001954, pac_md_common.f_get_cxtidioma)
                  || ': '
                  || onmovimi;
            ELSE
               vtmsg :=
                     f_axis_literales (151301, pac_md_common.f_get_cxtidioma)
                  || ' '
                  || onpoliza
                  || v_sncertif;
            END IF;
         /*  BUG 24722 AMJ 24/12/2012  Numero de Anexo en Impresion Fin*/
         ELSE
            vnumerr :=
               pac_seguros.f_get_nsolici_npoliza (osseguro,
                                                  NULL,
                                                  vsproduc,
                                                  NULL,
                                                  v_nsolici,
                                                  v_npoliza,
                                                  v_ncertif
                                                 );
            vtmsg :=
                  f_axis_literales (9903134, pac_md_common.f_get_cxtidioma)
               || ': '
               || v_npoliza;
            vtmsg :=
                  vtmsg
               || f_axis_literales (9903139, pac_md_common.f_get_cxtidioma)
               || '.';
            vtmsg :=
                  vtmsg
               || f_axis_literales (9903140, pac_md_common.f_get_cxtidioma)
               || '.';
         END IF;
      END IF;

      /* Fin bug 20672*/
      /* Si hay errores en la emisi??e suplementos se hace rollback de todo!*/
      /*END IF;*/
      /* BUG9640:DRA:22/04/2009:Fi*/
      IF indice_e = 0 AND indice >= 1
      THEN
         /* I - 31/10/2012 jlb - 23823*/
         /* Llamo a las listas restringidas*/
         /* Accion: anulaci??e p??a*/
         vnumerr :=
            pac_listarestringida.f_valida_listarestringida
                                (osseguro,
                                 NVL (onmovimi, 1),
                                 NULL,
                                 4,
                                 NULL,
                                 NULL,
                                 NULL /* Bug 31411/175020 - 16/05/2014 - AMC*/
                                );

         IF vnumerr <> 0
         THEN
            RETURN vnumerr;
         END IF;

         vnumerr :=
            pac_listarestringida.f_valida_listarestringida (osseguro,
                                                            NVL (onmovimi, 1),
                                                            NULL,
                                                            5,
                                                            NULL,
                                                            NULL,
                                                            NULL
                                                           /* Bug 31411/175020 - 16/05/2014 - AMC*/
                                                           );

         IF vnumerr <> 0
         THEN
            RETURN vnumerr;
         END IF;

         /* F - 31/10/2012- jlb - 23823*/
         /*Emissió correcta de la pólissa.*/
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 0, vtmsg);
         RETURN 0;
      ELSE
         ROLLBACK;                       /* dra 27-10-2008: bug mantis 7519*/
         pac_alctr126.borrar_tablas_est (psolicit);
         vpasexec := 21;
         /*Error en l'emissió de la pólissa, retenim la pólissa.*/
         /* BUG9640:DRA:30-03-2009: Inici*/
         vnumerr :=
            pac_emision_mv.f_retener_poliza ('SEG',
                                             osseguro,
                                             1,
                                             onmovimi,
                                             NVL (v_cmotret, 5),
                                             1,
                                             f_sysdate
                                            );

         /* BUG9640:DRA:30-03-2009: Fi*/
         /*nmovimi (JAS)*/
         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         /* BUG 27642 - FAL - 24/04/2014*/
         IF pmensaje IS NOT NULL
         THEN
            vnumerr :=
                 pac_motretencion.f_set_retencion (osseguro, 1, onmovimi, 53);

            IF vnumerr <> 0
            THEN
               RAISE e_object_error;
            END IF;

            /*

            v_existe := 0;

            SELECT COUNT(1)
              INTO v_existe
              FROM motretencion
             WHERE sseguro = osseguro
               AND nmovimi = onmovimi
               AND nriesgo = 1
               AND cmotret = 53;

            IF v_existe = 0 THEN
               BEGIN
                  SELECT NVL(MAX(nmotret), 0) + 1
                    INTO n_nmotret
                    FROM motretencion
                   WHERE sseguro = osseguro
                     AND nmovimi = onmovimi
                     AND nriesgo = 1;
               END;

               INSERT INTO motretencion
                           (sseguro, nriesgo, nmovimi, cmotret, cusuret,
                            freten, nmotret, cestgest)
                    VALUES (osseguro, 1, onmovimi, 53, pac_md_common.f_get_cxtusuario,
                            f_sysdate, n_nmotret, NULL);
            END IF;
            */
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 0, vtmsg);
         ELSE
            /* FI BUG 27642*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 0, vtmsg);
         END IF;

         RETURN 1;
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam || '-1-' || vvsseguro
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam || '-2-' || vvsseguro
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam || '-3-' || vvsseguro,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_emitir_propuesta;

   /*************************************************************************
      Antes de emitir la propuesta debe pasar por una serie de controles para saber
      la propuesta debe quedar retenida o no. Dicha función realiza dichos controles,
      dejando la póliza retenida si corresponde.
      param in psolicit   : número de solicitud
      param in pnmovimi   : número de movimiento
      param out mensajes  : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error o codigo error
      28-01-2010 BUG 11408 PSU (PolÃ­tica de Subscripció)
   *************************************************************************/
   FUNCTION f_control_emision (
      psolicit   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      ocreteni   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr      NUMBER (8)                := 0;
      vterror      VARCHAR2 (1000);
      vcreteni     NUMBER (8);
      vpasexec     NUMBER (8)                := 1;
      vparam       VARCHAR2 (500)
         := 'parámetros - psolicit: ' || psolicit || ' - pnmovimi: '
            || pnmovimi;
      vobject      VARCHAR2 (200)    := 'PAC_MD_PRODUCCION.F_Control_Emision';
      vsproduc     productos.sproduc%TYPE;
      vparampsu    NUMBER (1);
      vcidioma     idiomas.cidioma%TYPE;
      vcontareci   NUMBER (10);
      vaccion      NUMBER (1);
      lmensaje     VARCHAR2 (500)            := NULL;
      vsproces     NUMBER;
      lsproces     NUMBER;
      lmotivo      NUMBER                    := 10;
      v_cempres    estseguros.cempres%TYPE;
      v_moneda     NUMBER;
      vssegpol     NUMBER;
      w_motiu      NUMBER;
   BEGIN
      IF psolicit IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      /*Esborrat dels motius de retenció de l'emissió*/
      /* BUG11288:DRA:27/05/2010:Inici*/
      DELETE FROM estmotreten_rev
            WHERE sseguro = psolicit;

      /* BUG11288:DRA:27/05/2010:Fi*/
      DELETE FROM estmotretencion
            WHERE sseguro = psolicit;

      UPDATE estseguros
         SET creteni = 0
       WHERE sseguro = psolicit;

      SELECT sproduc, cempres
        INTO vsproduc, v_cempres
        FROM estseguros
       WHERE sseguro = psolicit;

      /* JLB - I - BUG 18423 COjo la moneda del producto*/
      /* v_moneda := f_parinstalacion_n('MONEDAINST');*/
      v_moneda := pac_monedas.f_moneda_producto (vsproduc);
      /* JLB - f - BUG 18423 COjo la moneda del producto*/
      /* 11408 - Per determinar si anem pel nou sistema PSU o pel tracional.*/
      vparampsu := pac_parametros.f_parproducto_n (vsproduc, 'PSU');

      IF NVL (vparampsu, 0) = 0
      THEN
         /*Comprovem si la pólissa ha de quedar retinguda per definició del producte*/
         vpasexec := 3;

         /*BUG6936-12022009-XVM*/
         IF NOT pac_iax_produccion.isaltacol
         THEN
            vnumerr := pac_productos.f_get_creteni (psolicit, vcreteni);
         ELSE
            vnumerr := 0;
            vcreteni := 0;
         END IF;

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         /* Bug 16095 - APD - 05/11/2010*/
         /* Los suplementos no se deben quedar retenidos para el producto 463.-GROUPLIFE*/
         IF vcreteni = 1
         THEN
            IF     pac_iax_produccion.issuplem
               AND                               /* estamos en un suplemento*/
                   NVL (f_parproductos_v (vsproduc, 'RETENER_SUPLEM'), 1) = 0
            THEN
               /* no se retienen los suplementos*/
               vcreteni := 0;   /* NO QUEREMOS QUE LA POLIZA QUEDE RETENIDA*/
            END IF;
         END IF;

         /* Fin Bug 16095 - APD - 05/11/2010*/
         /*BUG6936-12022009-XVM*/
         IF vcreteni = 1
         THEN
            vpasexec := 4;
            vnumerr :=
               pac_emision_mv.f_retener_poliza ('EST',
                                                psolicit,
                                                1,
                                                pnmovimi,
                                                6,
                                                2,
                                                f_sysdate
                                               );
         /* jlb - 06/04/2011*/
         ELSIF vcreteni = 5
         THEN
            vpasexec := 41;
            vnumerr :=
               pac_emision_mv.f_retener_poliza ('EST',
                                                psolicit,
                                                1,
                                                pnmovimi,
                                                6,
                                                5,
                                                f_sysdate
                                               );
         ELSE
            vpasexec := 5;
            /*Abans de l'emissió de la pólissa es comprova si aquesta queda retinguda.*/
            pac_emision_mv.p_control_antes_emision (psolicit,
                                                    f_sysdate,
                                                    pnmovimi,
                                                    vcreteni,
                                                    vnumerr,
                                                    vterror
                                                   );

            IF vcreteni = 0 AND (vnumerr <> 0 OR vterror IS NOT NULL)
            THEN
               /*Si s'ha produit un error de PL en la funció de control d'emissió, peró la pólissa*/
               /*no ha quedat retinguda, retenim la pólissa perquÃ¨ no es pot emetre.*/
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     vnumerr,
                                                     vterror
                                                    );
               vnumerr :=
                  pac_emision_mv.f_retener_poliza ('EST',
                                                   psolicit,
                                                   1,
                                                   pnmovimi,
                                                   5,
                                                   1,
                                                   f_sysdate
                                                  );
               vcreteni := 1;
            ELSIF vcreteni <> 0 AND vterror IS NOT NULL
            THEN
               /*Si la pólissa estÃ  retinguda, i la retenció tá un missatge associat, el mostrem.*/
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     2,
                                                     vnumerr,
                                                     vterror
                                                    );
            END IF;
         END IF;

         /*BUG 19484 - 19/10/2011 - JRB - Se a??n las funciones est para el reaseguro.*/
         IF     NVL (pac_parametros.f_parempresa_n (v_cempres,
                                                    'REASEGURO_EST'),
                     0
                    ) = 1
            AND pac_cesionesrea.producte_reassegurable (vsproduc) = 1
         THEN
            vpasexec := 7;

            IF vsproces IS NULL
            THEN
               vnumerr :=
                  f_procesini (f_user,
                               v_cempres,
                               'REASEGURO_EST',
                               'Retencion por facultativo',
                               lsproces
                              );
            ELSE
               lsproces := vsproces;
            END IF;

            vpasexec := 8;

            IF pac_iax_produccion.issuplem
            THEN
               w_motiu := 4;
            ELSE
               w_motiu := 3;
            END IF;

            vnumerr :=
               pac_cesionesrea.f_buscactrrea_est (psolicit,
                                                  pnmovimi,
                                                  lsproces,
                                                  w_motiu,
                                                  v_moneda
                                                 );

            IF vnumerr <> 0 AND vnumerr <> 99
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     vnumerr,
                                                     vterror
                                                    );
               vcreteni := 1;
            ELSIF vnumerr = 0
            THEN
               vpasexec := 9;
               vnumerr :=
                   pac_cesionesrea.f_cessio_est (lsproces, w_motiu, v_moneda);

               IF vnumerr <> 0 AND vnumerr <> 99
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                        1,
                                                        vnumerr,
                                                        vterror
                                                       );
                  vcreteni := 1;
               ELSIF vnumerr = 99
               THEN
                  vnumerr :=
                     pac_emision_mv.f_retener_poliza ('EST',
                                                      psolicit,
                                                      1,
                                                      pnmovimi,
                                                      lmotivo,
                                                      1,
                                                      f_sysdate
                                                     );
                  /*pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr, vterror);   --> Por facultativo*/
                  vcreteni := 0;
               END IF;
            END IF;

            IF vcreteni != 0
            THEN
               UPDATE estseguros
                  SET creteni = 2
                WHERE sseguro = psolicit;
            END IF;
         END IF;
      ELSE
         -- De IF NVL(vparampsu,'0') = 0 THEN
         IF pac_iax_produccion.issuplem
         THEN
            vaccion := 2;                                     /* Suplements*/
         ELSE
            vaccion := 1;                                 /* Nova producció*/
         END IF;

         vcidioma := pac_md_common.f_get_cxtidioma;
         vnumerr :=
            pac_psu.f_inicia_psu ('EST', psolicit, vaccion, vcidioma,
                                  vcreteni);

         IF vnumerr != 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                  1,
                                                  vnumerr,
                                                  vterror
                                                 );
            vcreteni := 1;
         END IF;

         IF vcreteni != 0
         THEN
            UPDATE estseguros
               SET creteni = 2
             WHERE sseguro = psolicit;
         END IF;
      END IF;

      ocreteni := vcreteni;
      vpasexec := 6;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_control_emision;

   /*************************************************************************
      Borrar registros en las tablas est
      param in psolicit   : número de solicitud
      param out mensajes  : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error o codigo error
   *************************************************************************/
   PROCEDURE borrar_tablas_est (
      psolicit   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'parámetros - psolicit: ' || psolicit;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.Borrar_Tablas_Est';
   BEGIN
      pac_alctr126.borrar_tablas_est (psolicit);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
   END borrar_tablas_est;

/************************************************************************
                             FI EMISIO
************************************************************************/
/************************************************************************
                          INICI CONSULTA
************************************************************************/
/* BUG 9017 - 01/04/2009 - SBG - S'afegeix parÃ metre p_filtroprod*/
/*************************************************************************
   Devuelve las pólizas que cumplan con el criterio de selección
   param in psproduc     : código de producto
   param in pnpoliza     : número de póliza
   param in pncert       : número de cerificado por defecto 0
   param in pnnumide     : número identidad persona
   param in psnip        : número identificador externo
   param in pbuscar      : nombre+apellidos a buscar de la persona
   param in ptipopersona : tipo de persona
                            1 tomador
                            2 asegurado
      param in pcmodo       : modo. Para pignoraciones vale 1
   param in p_filtroprod : Tipo de productos requeridos:
                           'TF'         ---> Contratables des de Front-Office
                           'REEMB'      ---> Productos de salud
                           'APOR_EXTRA' ---> Con aportaciones extra
                           'SIMUL'      ---> Que puedan tener simulación
                           'RESCA'      ---> Que puedan tener rescates
                           'SINIS'      ---> Que puedan tener siniestros
                           null         ---> Todos los productos
   param out mensajes    : mensajes de error
   return                : ref cursor
*************************************************************************/
/*13-08-2009:  XPL BUG 0010093, se añade el cramo, consulta polizas*/
   FUNCTION f_consultapoliza (
      pramo              IN       NUMBER,
      psproduc           IN       NUMBER,
      pnpoliza           IN       NUMBER,
      pncert             IN       NUMBER DEFAULT -1,
      pnnumide           IN       VARCHAR2,
      psnip              IN       VARCHAR2,
      pbuscar            IN       VARCHAR2,
      pnsolici           IN       NUMBER,
      /*bug15468 05/08/2010 VCL Añadir camp número solicitud*/
      ptipopersona       IN       NUMBER,
      pcagente           IN       NUMBER,     /*BUG 11313 - JTS - 29/10/2009*/
      pcmatric           IN       VARCHAR2,        /*BUG19605:LCF:19/02/2010*/
      pcpostal           IN       VARCHAR2,        /*BUG19605:LCF:19/02/2010*/
      ptdomici           IN       VARCHAR2,        /*BUG19605:LCF:19/02/2010*/
      ptnatrie           IN       VARCHAR2,        /*BUG19605:LCF:19/02/2010*/
      pcsituac           IN       NUMBER,          /*BUG19605:LCF:19/02/2010*/
      p_filtroprod       IN       VARCHAR2,
      pcpolcia           IN       VARCHAR2,
      /* BUG 14585 - PFA - Anadir campo poliza compania*/
      pccompani          IN       NUMBER,
      /* BUG 17160 - JBN - Anadir campo compani*/
      pcactivi           IN       NUMBER,         /* BUG18024:DRA:14/04/2011*/
      pcestsupl          IN       NUMBER,         /* BUG18024:DRA:14/04/2011*/
      pnpolrelacionada   IN       NUMBER,
      pnpolini           IN       VARCHAR2,        /*BUG19715:XPL:06/12/2011*/
      mensajes           IN OUT   t_iax_mensajes,
      pfilage            IN       NUMBER DEFAULT 1,
      /* BUG 16730: JMC : 26/04/2011*/
      pcsucursal         IN       NUMBER DEFAULT NULL,
      /* Bug 22839/126886 - 29/10/2012 - AMC*/
      pcadm              IN       NUMBER DEFAULT NULL,
      /* Bug 22839/126886 - 29/10/2012 - AMC*/
      pcmotor            IN       VARCHAR2 DEFAULT NULL,
      /* Bug 25177/133016 - 07/01/2013 - AMC*/
      pcchasis           IN       VARCHAR2 DEFAULT NULL,
      /* Bug 25177/133016 - 07/01/2013 - AMC*/
      pnbastid           IN       VARCHAR2 DEFAULT NULL,
      /* Bug 25177/133016 - 07/01/2013 - AMC*/
      pcmodo             IN       NUMBER DEFAULT NULL,
      /* Bug 27766 10/12/2013*/
      pncontrato         IN       VARCHAR2 DEFAULT NULL,      -- AP CONF - 219
      pfemiini           IN       DATE DEFAULT NULL,
      -- CJMR 22/03/2019 IAXIS-3195
      pfemifin           IN       DATE DEFAULT NULL,
      -- CJMR 22/03/2019 IAXIS-3195
      pfefeini           IN       DATE DEFAULT NULL,
      -- CJMR 22/03/2019 IAXIS-3195
      pfefefin           IN       DATE DEFAULT NULL,
      -- CJMR 22/03/2019 IAXIS-3195
      pcusuari           IN       VARCHAR2 DEFAULT NULL,
      -- CJMR 22/03/2019 IAXIS-3195
      pnnumidease        IN       VARCHAR2 DEFAULT NULL,
      -- CJMR 22/03/2019 IAXIS-3195
      pbuscarase         IN       VARCHAR2
            DEFAULT NULL                         -- CJMR 22/03/2019 IAXIS-3195
   )
      RETURN sys_refcursor
   IS
      cur              sys_refcursor;
      squery           VARCHAR2 (5000);
      /* Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación*/
      /*                                se añade la subselect con la tabla agentes_agente*/
      buscar           VARCHAR2 (5000) := ' where 1=1 ';
      /* Bug 10127 - APD - 19/05/2009 - fin*/
      subus            VARCHAR2 (2000);          -- CJMR 22/03/2019 IAXIS-319
      tabtp            VARCHAR2 (30);
      tabtp_ase        VARCHAR2 (20);               /* 15638 AVT 17-09-2010*/
      tabtp_con        VARCHAR2 (50);
      /* Bug 25177/133016 - 07/01/2013 - AMC*/
      tabtp_pag        VARCHAR2 (50);
      /* Bug 25151/137983 - 04/03/2013 - AMC*/
      auxnom           VARCHAR2 (200);
      v_nom            VARCHAR2 (200);              /* 15638 AVT 09-08-2010*/
      empresa          NUMBER;                      /* 15638 AVT 09-08-2010*/
      nerr             NUMBER;
      v_sentence       VARCHAR2 (500);
      v_query_agente   VARCHAR2 (5000);
      vpasexec         NUMBER (8)      := 1;
      vform            VARCHAR2 (5000) := '';
      vparam           VARCHAR2 (500)
         :=    'psproduc='
            || psproduc
            || ' pnpoliza: '
            || pnpoliza
            || ' pncert='
            || pncert
            || ' pnnumide='
            || pnnumide
            || ' psnip='
            || psnip
            || ' pbuscar='
            || pbuscar
            || ' ptipopersona='
            || ptipopersona
            || ' pnsolici='
            || pnsolici
            || ' pcmatric='
            || pcmatric
            || ' pcpostal='
            || pcpostal
            || ' ptdomici='
            || ptdomici
            || ' ptnatrie='
            || ptnatrie
            || ' p_filtroprod='
            || p_filtroprod
            || 'pcpolcia='
            || pcpolcia
            || ' pccompani= '
            || pccompani   /* BUG 14585 - PFA - Anadir campo poliza compania*/
            || ' pcactivi= '
            || pcactivi
            || ' pcestsupl= '
            || pcestsupl
            || ' pnpolrelacionada= '
            || pnpolrelacionada;
      vobject          VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.F_ConsultaPoliza';
      v_max_reg        NUMBER;        /* número mÃ xim de registres mostrats*/
   BEGIN
      /*bug 27766*/
      /* BUG19069:DRA:27/09/2011:Inici*/
      /* Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol*/
      /* Bug 20656 -APD - 22/11/2011 - se elimina la siguiente condicidion de la select:*/
      /* pac_corretaje.f_tiene_corretaje (s.sseguro) = 0 AND '*/
      /* ini BUG 0025581 - 11/01/2013 - JMF*/
      /************************************
      buscar :=
         buscar || ' AND ((pac_corretaje.f_tiene_corretaje (s.sseguro) = 1 AND ('
         || pac_md_common.f_get_cxtagente || ' = s.cagente OR '
         || pac_md_common.f_get_cxtagente
         || ' IN (SELECT ctj.cagente FROM age_corretaje ctj WHERE ctj.sseguro = s.sseguro)))'
         || ' OR ((s.cagente, s.cempres) IN (select aa.cagente, aa.cempres from agentes_agente_pol aa)))';
      ************************************/
      v_query_agente := 's.cagente';

      IF p_filtroprod = 'PIGNORACION'
      THEN
         IF NVL
               (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'FILTRO_PLEDGE'
                                           ),
                0
               ) = 1
         THEN
            /* Si entramos aquÃ­ es que debemos filtrar la consulta por aquellos pignorados a mi*/
            v_query_agente :=
                  '(SELECT ''1'' FROM agentes a, bloqueoseg b, agentes c '
               || ' WHERE a.sperson(+) = b.sperson'
               || ' AND c.ctipage = 0 '
               || ' AND b.sseguro = s.sseguro '
               || ' AND b.cmotmov = 261 '
               || ' AND (b.ffinal IS NULL OR b.ffinal > TRUNC (f_sysdate))'
               || ' AND NVL(a.cagente, c.cagente) in (SELECT aa.cagente FROM agentes_agente_pol aa)'
               || ' )'
               || ' OR ( s.cagente IN (SELECT aa.cagente FROM   agentes_agente_pol aa) )';
         END IF;
      END IF;

      IF pcmodo IS NULL OR pcmodo = 0
      THEN
         IF p_filtroprod = 'PIGNORACION'
         THEN
            buscar :=
                  buscar
               || ' AND ((pac_corretaje.f_tiene_corretaje (s.sseguro) = 1 AND ('
               || pac_md_common.f_get_cxtagente
               || ' = s.cagente OR '
               || ' exists '
               || ' (SELECT 1 FROM age_corretaje ctj, agentes_agente_pol bb'
               || ' WHERE ctj.sseguro=s.sseguro and bb.cempres=s.cempres and bb.cagente=ctj.cagente)'
               || '))'
               || ' OR exists'
               || v_query_agente
               || ')';
         ELSE
            buscar :=
                  buscar
               || ' AND ((pac_corretaje.f_tiene_corretaje (s.sseguro) = 1 AND ('
               || pac_md_common.f_get_cxtagente
               || ' = s.cagente OR '
               || ' exists '
               || ' (SELECT 1 FROM age_corretaje ctj, agentes_agente_pol bb'
               || ' WHERE ctj.sseguro=s.sseguro and bb.cempres=s.cempres and bb.cagente=ctj.cagente)'
               || '))'
               || ' OR (('
               || v_query_agente
               || ', s.cempres) IN (select aa.cagente, aa.cempres from agentes_agente_pol aa)))';
         END IF;
      END IF;

      /* fin BUG 0025581 - 11/01/2013 - JMF*/
      /* fin Bug 20656 -APD - 22/11/2011*/
      /* BUG19069:DRA:27/09/2011:Fi*/
      IF NVL (psproduc, 0) <> 0
      THEN
         buscar := buscar || ' and s.sproduc =' || psproduc;
      ELSE
         nerr := pac_productos.f_get_filtroprod (p_filtroprod, v_sentence);

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         IF v_sentence IS NOT NULL
         THEN
            buscar :=
                  buscar
               || ' and s.sproduc in (select p.sproduc from productos p where'
               || v_sentence
               || ' 1=1)';
         END IF;

         IF pramo IS NOT NULL
         THEN
            buscar :=
                  buscar
               || ' and s.sproduc in (select p.sproduc from productos p where'
               || ' p.cramo = '
               || pramo
               || ' )';
         END IF;
      END IF;

      IF p_filtroprod IN ('SALDAR', 'PRORROGAR')
      THEN
         buscar := buscar || ' and s.csituac = 0 and s.creteni = 0 ';
      END IF;

      /* ini BUG 0019931 - 10/01/2012 - JMF*/
      IF p_filtroprod = 'SINIESTRO'
      THEN
         buscar := buscar || ' and s.csituac <> 4 ';
      END IF;

      /* fin BUG 0019931 - 10/01/2012 - JMF*/
      IF pnpoliza IS NOT NULL
      THEN
         buscar :=
             buscar || ' and s.npoliza = ' || CHR (39) || pnpoliza
             || CHR (39);
      END IF;

      /*bug15468 05/08/2010 VCL*/
      IF pnsolici IS NOT NULL
      THEN
         buscar := buscar || ' and s.nsolici = ' || pnsolici;
      END IF;

      /*FI bug15468 05/08/2010 VCL*/
      /*      pnpolini IN VARCHAR2,   --BUG19715:XPL:06/12/2011*/
      IF pnpolini IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro IN ( SELECT SSEGURO from CNVPOLIZAS WHERE POLISSA_INI =  '
            || CHR (39)
            || pnpolini
            || CHR (39)
            || ')';
      END IF;

      IF pnpolrelacionada IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro IN ( select SSEGURO from pregunpolseg where CPREGUN IN (9738, 9739, 9740) AND TRESPUE =  '
            || pnpolrelacionada
            || ')';
      END IF;

      /*FI --BUG19715:XPL:06/12/2011*/
      /*bug 16730 26/04/2011 JMC*/
      IF pfilage = 0
      THEN
         IF NVL
               (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'FILTRO_AGE'
                                           ),
                0
               ) = 1
         THEN
            /*Bug.: 0016730 - ICV - 06/05/2011*/
            buscar :=
                  buscar
               || ' and s.cagente in (SELECT a.cagente
                                            FROM (SELECT     LEVEL nivel, cagente
                                                        FROM redcomercial r
                                                       WHERE
                                                          r.fmovfin is null
                                                  START WITH
                                                          r.cagente = '
               || pac_md_common.f_get_cxtagente ()
               || ' AND r.cempres = '
               || pac_md_common.f_get_cxtempresa ()
               || ' and r.fmovfin is null
                                                  CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
                                                         AND PRIOR r.cempres =(r.cempres + 0)
                                                         and r.fmovfin is null
                                                         AND r.cagente >= 0) rr,
                                                 agentes a
                                           where rr.cagente = a.cagente)';
         END IF;
      END IF;

      /*Fi bug 16730 26/04/2011 JMC*/
      IF pcpolcia IS NOT NULL
      THEN
         IF NVL
               (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'BUSCA_POL_ANTIG'
                                           ),
                0
               ) = 1
         THEN
            buscar :=
                  buscar
               || ' and upper(s.cpolcia) = '
               || CHR (39)
               || pcpolcia
               || CHR (39);
         ELSE
            buscar :=
                  buscar
               || ' and upper(s.cpolcia) like '
               || CHR (39)
               || '%'
               || pcpolcia
               || '%'
               || CHR (39);
         END IF;
      END IF;

      IF NVL (pncert, -1) <> -1
      THEN
         buscar := buscar || '  and s.ncertif =' || pncert;
      END IF;

      /* FINAL BUG 9017 - 01/04/2009 - SBG*/
      /*BUG 11313 - JTS - 29/10/2009*/
      IF pcagente IS NOT NULL
      THEN
         buscar := buscar || ' and s.cagente = ' || pcagente;
      END IF;

      /* BUG19605:LCF:19/02/2010:inici*/
      IF pcsituac IS NOT NULL
      THEN
         buscar := buscar || ' and s.csituac = ' || pcsituac;
      ELSIF pcpolcia IS NULL AND pnpoliza IS NULL AND pnsolici IS NULL
      THEN
         buscar := buscar || ' and s.csituac != 16 ';
      /*No esten en estado traspasadas*/
      END IF;

      IF pcmatric IS NOT NULL
      THEN
         /* Bug 25177/133016 - 07/01/2013 - AMC*/
         buscar :=
               buscar
            || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
            || ' where s.sseguro = aut.sseguro and aut.cmatric like ''%'
            || pcmatric
            || '%''';
         buscar := buscar || ') ';
      /* Fi Bug 25177/133016 - 07/01/2013 - AMC*/
      /* FAL - 03/11/2011 - 0020008: Consulta Pólizas Autos devuelve más de un registro*/
      END IF;

      /* Bug 25177/133016 - 07/01/2013 - AMC*/
      IF pcmotor IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
            || ' where s.sseguro = aut.sseguro and aut.codmotor like ''%'
            || pcmotor
            || '%''';
         buscar := buscar || ') ';
      END IF;

      IF pcchasis IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
            || ' where s.sseguro = aut.sseguro and aut.cchasis like ''%'
            || pcchasis
            || '%''';
         buscar := buscar || ') ';
      END IF;

      IF pnbastid IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
            || ' where s.sseguro = aut.sseguro and aut.nbastid like ''%'
            || pnbastid
            || '%''';
         buscar := buscar || ') ';
      END IF;

      /* Fi Bug 25177/133016 - 07/01/2013 - AMC*/
      IF pcpostal IS NOT NULL OR ptdomici IS NOT NULL
      THEN
         vform := vform || ' , sitriesgo sit ';
      END IF;

      /* BUG 17160: JBN INICI*/
      IF pccompani IS NOT NULL
      THEN
         buscar := buscar || ' and s.CCOMPANI = ' || pccompani;
      END IF;

      /* BUG 17160: JBN FI*/
      IF pcpostal IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and sit.sseguro = s.sseguro and upper(sit.cpostal) like upper(''%'
            || pcpostal
            || '%'')';
      END IF;

      IF ptdomici IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and sit.sseguro = s.sseguro and upper(sit.tdomici) like upper(''%'
            || ptdomici
            || '%'')';
      END IF;

      IF ptnatrie IS NOT NULL
      THEN
         vform := vform || ' , riesgos rie ';
         buscar :=
               buscar
            || ' and rie.sseguro = s.sseguro and upper(rie.tnatrie) like upper(''%'
            || ptnatrie
            || '%'')';
      END IF;

      /* BUG19605:LCF:19/02/2010:fi*/
      /* BUG18024:DRA:14/04/2011:Inici*/
      IF pcactivi IS NOT NULL
      THEN
         buscar := buscar || ' and s.cactivi = ' || pcactivi;
      END IF;

      /* BUG18024 JLB - 28/04/2008 -- Esto es mal, puede devolver mas de un registro,*/
      /*IF pcestsupl IS NOT NULL THEN
         buscar :=
            buscar || ' and ' || pcestsupl || ' = (SELECT sup.cestsup FROM sup_solicitud sup'
            || ' WHERE sup.sseguro = s.sseguro AND sup.nmovimi = (SELECT MAX (sup1.nmovimi)'
            || ' FROM sup_solicitud sup1 WHERE sup1.sseguro = sup.sseguro))';
      END IF;
      */
      IF pcestsupl IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and EXISTS (SELECT 1 FROM sup_solicitud sup'
            || ' WHERE sup.sseguro = s.sseguro and cestsup = '
            || pcestsupl
            || ')';
      END IF;

      /* BUG18024 JLB - 28/04/2008 -- Esto es mal, puede devolver mas de un registro,*/
      /* BUG18024:DRA:14/04/2011:Fi*/
      /* 15638 AVT 09-08-2010*/
      v_nom := ' pac_iax_listvalores.f_get_nametomador(s.sseguro, 1) ';

      IF NVL (ptipopersona, 0) > 0
      THEN
         IF ptipopersona = 1
         THEN
            /* Prenador*/
            tabtp := 'TOMADORES';
         ELSIF NVL (ptipopersona, 0) = 2
         THEN
            /* Asegurat*/
            /* 15638 AVT 09-08-2010*/
            empresa := f_parinstalacion_n ('EMPRESADEF');

            IF NVL (pac_parametros.f_parempresa_t (empresa, 'NOM_TOM_ASEG'),
                    0
                   ) = 1
            THEN
               /*v_nom := ' pac_iax_listvalores.f_get_nameasegurado(s.sseguro, 1) ';*/
               v_nom := ' f_nombre(aa.sperson, 1, s.cagente) ';
               tabtp_ase := ', ASEGURADOS aa';
            END IF;
         /* Bug 25177/133016 - 07/01/2013 - AMC*/
         ELSIF ptipopersona = 3
         THEN
            /* Conductor*/
            tabtp_con := ', AUTCONDUCTORES aa';
         /* Bug 25151/137983 - 04/03/2013 - AMC*/
         ELSIF ptipopersona = 4
         THEN
            /* Pagador*/
            tabtp_pag := ', RECIBOS aa';
         END IF;
      END IF;

      /* 15638 AVT 09-08-2010 fin*/
      /* buscar per personas*/
      /****
      CJMR 22/03/2019 IAXIS-3195
      IF (pnnumide IS NOT NULL OR NVL(psnip, ' ') <> ' ' OR
         pbuscar IS NOT NULL) AND
         NVL(ptipopersona, 0) > 0
      THEN
         IF ptipopersona = 1
         THEN
            tabtp := 'TOMADORES';  -- Prenador
         ELSIF ptipopersona = 2
         THEN
            tabtp := 'ASEGURADOS';  -- Asegurat
         ELSIF ptipopersona = 3
         THEN
            tabtp := 'AUTCONDUCTORES';  -- Conductor
         ELSIF ptipopersona = 4
         THEN
            tabtp := 'RECIBOS';   -- Pagador
         END IF;

         IF tabtp IS NOT NULL
         THEN
            subus := ' and s.sseguro IN (SELECT a.sseguro FROM ' || tabtp ||
                     ' a, per_detper p, per_personas pp WHERE pp.sperson = p.sperson and a.sperson = p.sperson AND P.CAGENTE = FF_AGENTE_CPERVISIO (S.CAGENTE, F_SYSDATE, S.CEMPRES)';

            IF ptipopersona = 2
            THEN
               subus := subus || ' AND a.ffecfin IS NULL';  --Asegurat
            END IF;

            IF pnnumide IS NOT NULL
            THEN
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                    'NIF_MINUSCULAS'),
                      0) = 1
               THEN
                  subus := subus || ' AND UPPER(pp.nnumide)= UPPER(' ||
                           chr(39) || ff_strstd(pnnumide) || chr(39) || ')';
               ELSE
                  subus := subus || ' AND pp.nnumide like ' || chr(39) || '%' ||
                           ff_strstd(pnnumide) || '%' || chr(39) || '';
               END IF;
            END IF;

            IF NVL(psnip, ' ') <> ' '
            THEN
               subus := subus || ' AND upper(pp.snip)=upper(' || chr(39) ||
                        ff_strstd(psnip) || chr(39) || ')';
            END IF;

            IF pbuscar IS NOT NULL
            THEN
               nerr := f_strstd(pbuscar, auxnom);

               subus := subus || ' AND upper ( replace ( p.tbuscar, ' ||
                        chr(39) || '  ' || chr(39) || ',' || chr(39) || ' ' ||
                        chr(39) || ' )) like upper(''%' || auxnom || '%' ||
                        chr(39) || ')';
            END IF;

            subus := subus || ')';
         END IF;
      END IF;
      CJMR 22/03/2019 IAXIS-3195 */

      /* 15638 AVT 08-09-2010 s'afegeix el v_nom i la cerca per assegurat*/
      IF tabtp_ase IS NOT NULL
      THEN
         buscar := buscar || ' AND s.sseguro = aa.sseguro ';
      END IF;

      /* Bug 25177/133016 - 07/01/2013 - AMC*/
      IF tabtp_con IS NOT NULL
      THEN
         buscar := buscar || ' AND s.sseguro = aa.sseguro ';
      END IF;

      /* Bug 25151/137983 - 04/03/2013 - AMC*/
      IF tabtp_pag IS NOT NULL
      THEN
         buscar := buscar || ' AND s.sseguro = aa.sseguro ';
      END IF;

      /* Bug 22839/126886 - 29/10/2012 - AMC*/
      IF (pcsucursal IS NOT NULL AND pcsucursal != -1) OR
                                                         --CJMR 22/03/2019 IAXIS-3195
                                                         pcadm IS NOT NULL
      THEN
         vform := vform || ' ,seguredcom src ';
         buscar := buscar || ' AND s.sseguro = src.sseguro ';

         IF pcsucursal IS NOT NULL
         THEN
            buscar := buscar || ' AND src.c02 = ' || pcsucursal;
         END IF;

         IF pcadm IS NOT NULL
         THEN
            buscar := buscar || ' AND src.c03 = ' || pcadm;
         END IF;
      END IF;

      /* Fi Bug 22839/126886 - 29/10/2012 - AMC*/
      /* Ini Bug 27766 10/12/2013*/
      IF pcmodo = 1
      THEN
         buscar :=
               buscar
            || ' AND EXISTS (SELECT 1 FROM usuarios u, bloqueoseg b,agentes ag WHERE u.cusuari = '''
            || pac_md_common.f_get_cxtusuario
            || '''
                                  AND b.sseguro = s.sseguro AND b.ffinal IS NULL AND b.cmotmov = 261 AND ag.cagente = u.cdelega AND (Select sperson FROM agentes a
                          WHERE cagente = pac_redcomercial.f_busca_padre(u.cempres, u.cdelega, ag.ctipage, trunc(f_sysdate)) )  = b.sperson ) ';
      END IF;

      /* Fin Bug 27766*/

      --Ini CONF-219 AP
      IF pncontrato IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' AND EXISTS ( select 1 FROM PREGUNPOLSEG P WHERE p.sseguro = s.sseguro and p.nmovimi = '
            || '  (select max(nmovimi)from pregunpolseg p1 where p1.sseguro = p.sseguro and p1.cpregun = p.cpregun) '
            || ' and p.cpregun = 4097 AND p.trespue = '''
            || pncontrato
            || ''' ) ';
      END IF;

--Fi CONF-219 AP

      --INI CJMR 22/03/2019 IAXIS-3195
      -- Número de identificación y/o nombre del tomador
      IF pnnumide IS NOT NULL OR pbuscar IS NOT NULL
      THEN
         subus :=
               subus
            || ' AND s.sseguro IN (SELECT a.sseguro FROM tomadores a, '
            || ' per_personas pp, per_detper pdp WHERE a.sperson = pp.sperson '
            || ' AND a.sperson = pdp.sperson '
            || ' AND pdp.cagente = ff_agente_cpervisio (s.cagente, f_sysdate, s.cempres)';

         IF pnnumide IS NOT NULL
         THEN
            IF NVL
                  (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NIF_MINUSCULAS'
                                           ),
                   0
                  ) = 1
            THEN
               subus :=
                     subus
                  || ' AND UPPER(pp.nnumide) = UPPER('
                  || CHR (39)
                  || ff_strstd (pnnumide)
                  || CHR (39)
                  || ')';
            ELSE
               subus :=
                     subus
                  || ' AND pp.nnumide LIKE '
                  || CHR (39)
                  || '%'
                  || ff_strstd (pnnumide)
                  || '%'
                  || CHR (39)
                  || '';
            END IF;
         END IF;

         IF pbuscar IS NOT NULL
         THEN
            nerr := f_strstd (pbuscar, auxnom);
            subus :=
                  subus
               || ' AND UPPER ( REPLACE ( pdp.tbuscar, '
               || CHR (39)
               || '  '
               || CHR (39)
               || ','
               || CHR (39)
               || ' '
               || CHR (39)
               || ' )) LIKE UPPER(''%'
               || auxnom
               || '%'
               || CHR (39)
               || ')';
         END IF;

         subus := subus || ')';
      END IF;

      -- Numero de identificación y/o nombre del asegurado
      IF pnnumidease IS NOT NULL OR pbuscarase IS NOT NULL
      THEN
         subus :=
               subus
            || ' AND s.sseguro IN (SELECT a.sseguro FROM asegurados a, '
            || ' per_personas pp, per_detper pdp WHERE a.sperson = pp.sperson '
            || ' AND a.sperson = pdp.sperson '
            || ' AND pdp.cagente = ff_agente_cpervisio (s.cagente, f_sysdate, s.cempres)'
            || ' AND a.ffecfin IS NULL';

         IF pnnumidease IS NOT NULL
         THEN
            IF NVL
                  (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NIF_MINUSCULAS'
                                           ),
                   0
                  ) = 1
            THEN
               subus :=
                     subus
                  || ' AND UPPER(pp.nnumide) = UPPER('
                  || CHR (39)
                  || ff_strstd (pnnumidease)
                  || CHR (39)
                  || ')';
            ELSE
               subus :=
                     subus
                  || ' AND pp.nnumide LIKE '
                  || CHR (39)
                  || '%'
                  || ff_strstd (pnnumidease)
                  || '%'
                  || CHR (39)
                  || '';
            END IF;
         END IF;

         IF pbuscarase IS NOT NULL
         THEN
            nerr := f_strstd (pbuscarase, auxnom);
            subus :=
                  subus
               || ' AND UPPER ( REPLACE ( pdp.tbuscar, '
               || CHR (39)
               || '  '
               || CHR (39)
               || ','
               || CHR (39)
               || ' '
               || CHR (39)
               || ' )) LIKE UPPER(''%'
               || auxnom
               || '%'
               || CHR (39)
               || ')';
         END IF;

         subus := subus || ')';
      END IF;

      IF pfemiini IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' AND TRUNC(s.femisio) >= TO_DATE( '
            || ''''
            || TO_CHAR (pfemiini, 'DD/MM/YYYY')
            || ''''
            || ',''DD/MM/YYYY'')';
      END IF;

      IF pfemifin IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' AND TRUNC(s.femisio) <= TO_DATE( '
            || ''''
            || TO_CHAR (pfemifin, 'DD/MM/YYYY')
            || ''''
            || ',''DD/MM/YYYY'')';
      END IF;

      IF pfefeini IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' AND TRUNC(s.fefecto) >= TO_DATE( '
            || ''''
            || TO_CHAR (pfefeini, 'DD/MM/YYYY')
            || ''''
            || ',''DD/MM/YYYY'')';
      END IF;

      IF pfefefin IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' AND TRUNC(s.fefecto) <= TO_DATE( '
            || ''''
            || TO_CHAR (pfefefin, 'DD/MM/YYYY')
            || ''''
            || ',''DD/MM/YYYY'')';
      END IF;

      IF pcusuari IS NOT NULL
      THEN
         vform := vform || ' , movseguro mv ';
         buscar :=
               buscar
            || ' AND mv.sseguro = s.sseguro AND mv.cmotmov = '' 100 '' AND mv.cusumov = '
            || CHR (39)
            || pcusuari
            || CHR (39);
      END IF;

      --FIN CJMR 22/03/2019 IAXIS-3195

      /* Ini bug 17922 - 24/03/2011 - SRA*/
      squery :=
            'SELECT s.sseguro, TO_CHAR(s.npoliza) npoliza, s.ncertif, s.cpolcia,'
         /*bug 18561 - 15/05/2011 - JMC*/
         || 'PAC_IAXPAR_PRODUCTOS.f_get_parproducto(''ADMITE_CERTIFICADOS'', s.sproduc) mostra_certif,'
         || v_nom
         || 'AS nombre, PAC_IAX_LISTVALORES.F_Get_Sit_Pol_Detalle(s.sseguro) as situacion,'
         || ' s.sproduc, f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,PAC_MD_COMMON.f_get_cxtidioma) as desproducto,'
         || ' ff_descompania(s.ccompani) ccompani, null nnumide, null cmediad, null ccolabo, s.fefecto fefecto, null csinies, s.femisio femisio, null cplan, null clinea,'
         || ' s.cactivi, ff_desactividad (s.cactivi, s.cramo, PAC_MD_COMMON.f_get_cxtidioma, 2) tactivi, '
         || ' ff_desagente(s.cagente) tagente FROM seguros s '
         || vform
         || tabtp_ase
         || tabtp_con
         || tabtp_pag                 /* Bug 25151/137983 - 04/03/2013 - AMC*/
         || buscar                    /* Bug 25177/133016 - 07/01/2013 - AMC*/
         || subus;

      /* XPL#30/08/2011#19260, se aade el agente como salida*/
      IF NVL
            (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                            'EMP_POL_EXTERNA'
                                           ),
             0
            ) = 1
      THEN
         IF    NVL (pac_parametros.f_parproducto_n (psproduc,
                                                    'PRO_POL_EXTERNA'
                                                   ),
                    0
                   ) = 1
            OR psproduc IS NULL
         THEN
            DECLARE
               vsquery2   VARCHAR2 (4000);
            BEGIN
               vsquery2 :=
                     'select to_number (null) sseguro, es.npoliza, to_number (null) ncertif, null cpolcia, 0 mostra_certif, trim(es.tapell1)||CHR(32)||trim(es.tapell2)||CHR(32)||'', ''||CHR(32)||trim(es.tnombre) nombre,'
                  || ' decode(ctipmov,''B'',ff_desvalorfijo(61,PAC_MD_COMMON.f_get_cxtidioma,2),ff_desvalorfijo(61,PAC_MD_COMMON.f_get_cxtidioma,0)) situacion,'
                  || ' es.sproduc, f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect,1, PAC_MD_COMMON.f_get_cxtidioma) as desproducto,'
                  || ' ff_descompania(p.ccompani) ccompani, es.nnumide, es.cmediad, es.ccolabo, es.fefecto, decode(es.csinies, 1, f_axis_literales(101778,pac_md_common.f_get_cxtidioma), f_axis_literales(101779,pac_md_common.f_get_cxtidioma)) csinies, es.femisio,'
                  || ' pac_propio.f_get_planpoliza(es.idproduc, es.ccompani, es.sproduc) cplan, pac_propio.f_get_lineapoliza(es.idproduc, es.ccompani, es.sproduc) clinea,'
                  || ' to_number (null) cactivi, NULL tactivi, NULL tagente ';
               vsquery2 := vsquery2 || ' from ext_seguros es, productos p ';
               /* Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol*/
               vsquery2 :=
                     vsquery2
                  || ' where es.sproduc = p.sproduc and (es.ccolabo,pac_md_common.f_get_cxtempresa) in (select cagente,cempres from agentes_agente_pol) ';

               IF psproduc IS NOT NULL
               THEN
                  vsquery2 := vsquery2 || ' and p.sproduc = ' || psproduc;
               END IF;

               /* Bug : 19110 - 06/10/2011 - JMC - Se añade ramo y agente al filtro*/
               IF pramo IS NOT NULL
               THEN
                  vsquery2 :=
                        vsquery2
                     || ' and es.sproduc in (select p.sproduc from productos p where'
                     || ' p.cramo = '
                     || pramo
                     || ' )';
               END IF;

               IF pcagente IS NOT NULL
               THEN
                  vsquery2 :=
                        vsquery2
                     || ' and (es.cmediad = '
                     || pcagente
                     || ' or es.ccolabo = '
                     || pcagente
                     || ') ';
               END IF;

               /* Fin Bug : 19110 - 06/10/2011 - JMC*/
               IF pnpoliza IS NOT NULL
               THEN
                  vsquery2 :=
                        vsquery2
                     || ' and es.npoliza = '
                     || CHR (39)
                     || pnpoliza
                     || CHR (39);
               END IF;

               IF pccompani IS NOT NULL
               THEN
                  vsquery2 := vsquery2 || ' and es.ccompani = ' || pccompani;
               END IF;

               IF TRIM (pnnumide) IS NOT NULL
               THEN
                  /*Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015*/
                  IF NVL
                        (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NIF_MINUSCULAS'
                                           ),
                         0
                        ) = 1
                  THEN
                     vsquery2 :=
                           vsquery2
                        || ' and UPPER(es.nnumide) = UPPER('
                        || CHR (39)
                        || pnnumide
                        || CHR (39)
                        || ')';
                  ELSE
                     vsquery2 :=
                           vsquery2
                        || ' and es.nnumide = '
                        || CHR (39)
                        || pnnumide
                        || CHR (39);
                  END IF;
               END IF;

               IF pbuscar IS NOT NULL
               THEN
                  vsquery2 :=
                        vsquery2
                     || ' AND FF_STRSTD(TRIM(es.tnombre)||CHR(32)||TRIM(es.tapell1)||CHR(32)||TRIM(es.tapell2)||CHR(32)) LIKE '
                     || CHR (39)
                     || '%'
                     || auxnom
                     || '%'
                     || CHR (39);
               END IF;

               vsquery2 := ' UNION ALL ' || vsquery2;
               squery := squery || vsquery2;
            END;
         END IF;
      END IF;

      squery := squery || ' order by npoliza desc, ncertif desc nulls last';
                                          --2018/03/12 CJMR CONF-1315 / QT1956
      /* jlb I 28/04/2011 -- que haga priemro el rownum y luego el order by*/
      /*BUG 29358/151407 - 16/12/2013 - RCL - En Autorización masiva no se filta por rownum*/
      v_max_reg := pac_parametros.f_parinstalacion_n ('N_MAX_REG');

      IF p_filtroprod IS NULL OR p_filtroprod <> 'AUTORIZA_MASIVO'
      THEN
           --2018/03/12 CJMR CONF-1315 / QT1956
         --squery := squery || ' and rownum <= ' || v_max_reg;
         squery :=
             'select * from (' || squery || ') where rownum <= ' || v_max_reg;
      END IF;

      --squery := squery || ' order by npoliza desc, ncertif desc nulls last';   2018/03/12 CJMR CONF-1315 / QT1956

      /* Fin bug 17922 - 24/03/2011 - SRA*/
      /* BUG10127:DRA:19/05/2009:Inici*/
      /*IF v_max_reg IS NOT NULL THEN
         IF INSTR(squery, 'order by', -1, 1) > 0 THEN
            -- se hace de esta manera para mantener el orden de los registros
            squery := 'select * from (' || squery || ') where rownum <= ' || v_max_reg;
         ELSE
            squery := squery || ' and rownum <= ' || v_max_reg;
         END IF;
      END IF;*/
      /* jlb F - 28/04/2011*/
      /* BUG10127:DRA:19/05/2009:Fi*/
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);

      IF pac_md_log.f_log_consultas (squery,
                                     'PAC_MD_PRODUCCION.F_CONSULTAPOLIZA',
                                     1,
                                     2,
                                     mensajes
                                    ) <> 0
      THEN
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consultapoliza;

   /*************************************************************************
   Recupera información para el objeto poliza
   param in sseguro    : número de seguro
   param in pmode      : mode con el que recuperar información
   param out pproducto : código de producto
   param out pagente   : código de agente
   param out pempresa  : código empresa
   param out pfEfecto  : fecha efecto
   param out pfVencim  : fecha vencimiento
   param out mensajes  : mensajes de error
   return              : 0 todo correcto
                        1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_consultapoliza (
      psseguro    IN       NUMBER,
      pmode       IN       VARCHAR2,
      pnmovimi    OUT      NUMBER,
      pproducto   OUT      NUMBER,
      pagente     OUT      NUMBER,
      pempresa    OUT      NUMBER,
      pfefecto    OUT      DATE,
      pfvencim    OUT      DATE,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
         :=    'psseguro='
            || psseguro
            || ' pmode= '
            || pmode
            || ' pproducto='
            || pproducto
            || ' pagente='
            || pagente
            || ' pempresa='
            || pempresa
            || ' pfEfecto='
            || pfefecto
            || ' pfVencim='
            || pfvencim;
      vobject    VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.F_Set_ConsultaPoliza';
   BEGIN
      BEGIN
         IF pmode = 'POL'
         THEN
            SELECT sproduc, cagente, cempres, fefecto, fvencim
              INTO pproducto, pagente, pempresa, pfefecto, pfvencim
              FROM seguros
             WHERE sseguro = psseguro;

            IF pac_md_log.f_log_consultas
                     (   'select sproduc, cagente, cempres, fefecto, fvencim'
                      || CHR (10)
                      || 'from seguros'
                      || CHR (10)
                      || 'where sseguro = '
                      || psseguro,
                      'PAC_MD_PRODUCCION.F_SET_CONSULTAPOLIZA',
                      2,
                      2,
                      mensajes
                     ) <> 0
            THEN
               RETURN 1;
            END IF;
         ELSIF pmode = 'EST'
         THEN
            BEGIN
               SELECT sproduc, cagente, cempres, fefecto, fvencim
                 INTO pproducto, pagente, pempresa, pfefecto, pfvencim
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT sproduc, cagente, cempres, fefecto, fvencim
                       INTO pproducto, pagente, pempresa, pfefecto, pfvencim
                       FROM seguros
                      WHERE sseguro = psseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        NULL;
                  END;
            END;

            IF pac_md_log.f_log_consultas
                     (   'select sproduc, cagente, cempres, fefecto, fvencim'
                      || CHR (10)
                      || 'from estseguros'
                      || CHR (10)
                      || 'where sseguro = '
                      || psseguro,
                      'PAC_MD_PRODUCCION.F_SET_CONSULTAPOLIZA',
                      2,
                      2,
                      mensajes
                     ) <> 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes,
                                             1,
                                             -2321,
                                             'No se ha localizado la póliza.'
                                            );
            vpasexec := 2;
            RAISE e_object_error;
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes,
                                             1,
                                             -2321,
                                             'No se ha localizado la póliza.'
                                            );
            vpasexec := 3;
            RAISE e_object_error;
      END;

      /*(JAS)Recuperació del moviment a consultar.*/
      /*De moment recuperem l'últim moviment, peró más endevant haurem de parametritzar*/
      /*la consulta de pólisses de tal manera que l'usuri pugui indicar el moviment*/
      /*del qual desitja consultar les dades*/
      IF pmode = 'POL'
      THEN
         SELECT MAX (m.nmovimi)
           INTO pnmovimi
           FROM movseguro m
          WHERE m.sseguro = psseguro;
      ELSIF pmode = 'EST'
      THEN
         pnmovimi := 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_consultapoliza;

   /***********************************************************************
      Recupera los recibos de la póliza
      param in psolicit  : número de solicitud
      param out mensajes : mensajes de error
      return             : objeto detalle de la poliza
   ***********************************************************************/
   FUNCTION f_get_recibos (psolicit IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detrecibo
   IS
      squery           VARCHAR (5000);
      cur              sys_refcursor;
      rebuts           t_iax_detrecibo          := t_iax_detrecibo ();
      rebut            ob_iax_detrecibo         := ob_iax_detrecibo ();
      vidioma          NUMBER                := pac_md_common.f_get_cxtidioma;
      vpasexec         NUMBER (8)               := 1;
      vparam           VARCHAR2 (500)           := 'psolicit: ' || psolicit;
      vobject          VARCHAR2 (200)    := 'PAC_MD_PRODUCCION.F_Get_Recibos';
      vtabla           VARCHAR2 (200);
      /* BUG 25583/0136705 - FAL - 30/01/2013*/
      v_cond           VARCHAR2 (200);
      v_sproduc        productos.sproduc%TYPE;
      /* FI BUG 25583/0136705*/
      v_ncertif        seguros.ncertif%TYPE;
      vctipapor        NUMBER (3);
      vctipaportante   NUMBER (3);
      vdettiprec       NUMBER (3)               := NULL;
      v_sum_importe    NUMBER                   := 0;
      cuenta           NUMBER                   := 0;
   --INI SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
     --
     -- Inicio IAXIS-4926 23/10/2019
     --
     -- Se comentan las siguientes líneas de código al saberse que no se requieren dichos cambios.
     --
     --v_sseguro  recibos.sseguro%TYPE;
     --v_nmovimi  recibos.nmovimi%TYPE;
     --
     --v_importe_ab detmovrecibo.iimporte%TYPE;
     --
     --v_cmovseg movseguro.cmovseg%TYPE;
     --
     -- Fin IAXIS-4926 23/10/2019
     --
     --FIN SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
   BEGIN
      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'MONEDA_POL'
                                            ),
              0
             ) = 1
      THEN
         vtabla := 'vdetrecibos_monpol';
      ELSE
         vtabla := 'vdetrecibos';
      END IF;

      /* BUG 25583/0136705 - FAL - 30/01/2013*/
      BEGIN
         SELECT sproduc, ncertif
           INTO v_sproduc, v_ncertif
           FROM seguros
          WHERE sseguro = psolicit;

         v_cond := NULL;

         IF NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                 'ADMITE_CERTIFICADOS'
                                                ),
                 0
                ) = 1
         THEN
            IF NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                    'CONS_REC_AGRUP'
                                                   ),
                    0
                   ) = 1
            THEN
               IF v_ncertif = 0
               THEN
                  v_cond := 'AND r.cestaux <> 2';
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cond := NULL;
      END;

      /* FI BUG 25583/0136705*/
      -- Ini IAXIS-3592  -- ECP -- 24/05/2019
      squery := 'SELECT r.nrecibo,fefecto,fvencim,';
      /* BEGIN
          SELECT NVL (NVL (SUM (NVL (b.iconcep_monpol, 0)),
                           SUM (NVL (b.iconcep, 0))
                          ),
                      0
                     )
            INTO v_sum_importe
            FROM detmovrecibo a, detmovrecibo_parcial b
           WHERE a.nrecibo IN (SELECT nrecibo
                                 FROM recibos a, movseguro b
                                WHERE a.sseguro = psolicit
                                and a.sseguro = b.sseguro
                                and b.cmovseg = 53)
             AND a.nrecibo = b.nrecibo
             AND a.smovrec = (SELECT MAX (b.smovrec)
                                FROM detmovrecibo b
                               WHERE b.nrecibo = a.nrecibo)
             AND a.norden = b.norden
             AND b.cconcep IN (0, 4, 14, 86)
             AND b.nreccaj is null;
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             v_sum_importe := 0;
       END;*/

      -- Ini IAXIS-11899 --ECP --26/03/2020
      v_sum_importe := 0;

      -- Fin IAXIS-11899 --ECP --26/03/2020
      IF pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                        'VISIBLE_REC_COM_GES'
                                       ) = 1
      THEN
         squery :=
               squery
            || '(DECODE(itotalr,0,-1*v.ICOMBRU,itotalr)  - nvl('
            || v_sum_importe
            || ',0)) AS importe,';
      ELSE
         squery :=
                  squery || '(itotalr - ' || v_sum_importe || ') AS importe,';
      END IF;

      squery :=
            squery
         || ' (select itotalr - nvl('
         || v_sum_importe
         || ',0) from '
         || vtabla
         || ' aux where r.nrecibo=aux.nrecibo ) as importe_mon, '
         -- Fin IAXIS-11899 --ECP --03/03/2020
         /* ini Bug 0012679 - 18/02/2010 - JMF: CEM - Treure la taula MOVRECIBOI*/
         /******************************
                                        || ' cestrec, (select tatribu from detvalores where cvalor = 1
                                                         and catribu = cestrec
                                                         and cidioma = '
                                        || vidioma || ') as testrec  , '
                                       ******************************/
         || ' f_cestrec_mv(r.nrecibo,'
         || vidioma
         || ') cestrec,'
         || ' (SELECT tatribu FROM detvalores WHERE cvalor = 383 AND catribu = f_cestrec_mv(r.nrecibo,'
         || vidioma
         || ') AND cidioma = '
         || vidioma
         || ') AS testrec  , '
         /* fin Bug 0012679 - 18/02/2010 - JMF: CEM - Treure la taula MOVRECIBOI*/
         || ' ctiprec,DECODE(pac_md_common.f_get_cxtempresa,6,'
         || ' pac_gestion_rec.f_get_tipo_rec('
         || vidioma
         || ',r.nrecibo), ff_desvalorfijo( 8,'
         || vidioma
         || ',DECODE(ctiprec,3,DECODE(r.nfracci,0,3,16),ctiprec))) as ttiprec,r.creccia, esccero, '
         /*Bug 14586-PFA-25/05/2010- Añadir campo recibo compañia*/
         || ' pac_gestion_rec.f_desctiprec(r.nrecibo,'
         || vidioma
         || ') tdestiprec, '                        -- BUG23853:DRA:09/11/2012
         || 'ctipapor, ctipaportante '
         /* 07/10/2014 - 24926*/
         || ', csubtiprec,  ff_desvalorfijo( 800008 , '
         || vidioma
         || ', r.csubtiprec ) tsubtiprec '
         /**/
         || ' FROM recibos r, movrecibo m, '
         || vtabla
         || ' v '
         || ' WHERE  r.sseguro = '
         || psolicit
         || ' AND r.nrecibo = m.nrecibo AND m.smovrec = '
         || ' (SELECT MAX(m2.smovrec) FROM movrecibo m2 WHERE m2.nrecibo = m.nrecibo) '
         || ' AND r.nrecibo = v.nrecibo ';

      IF pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                        'VISIBLE_REC_COM_GES'
                                       ) = 1
      THEN
         squery := squery || ' AND (v.itotalr <> 0 OR v.icombru <>0)';
      ELSE
         squery := squery || ' AND v.itotalr <> 0 ';
      END IF;

      squery :=
            squery
         || v_cond                   /* BUG 25583/0136705 - FAL - 30/01/2013*/
         || ' ORDER BY TRUNC(r.fefecto) Desc, r.nrecibo DESC';
      -- Fin IAXIS-3592  -- ECP -- 24/05/2019
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);

      LOOP
         FETCH cur
          INTO rebut.nrecibo, rebut.fefecto, rebut.fvencim, rebut.importe,
               rebut.importe_mon, rebut.cestrec, rebut.testrec,
               rebut.ctiprec, rebut.ttiprec, rebut.creccia, rebut.esccero,
               rebut.tdestiprec, vctipapor, vctipaportante
                                                          /* 07/10/2014 - 24926*/
               , rebut.csubtiprec, rebut.tsubtiprec
                                                   /**/
         ;

         EXIT WHEN cur%NOTFOUND;

         /*La columna tipo recibo de detalle poliza puede requerir de algun literal especial que no está en detvalores dependiendo de otros campos*/
         IF NVL
               (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                               'LIT_TIP_REC_ESPECIAL'
                                              ),
                0
               ) = 1
         THEN
            IF rebut.ctiprec = 4 AND vctipapor = 4 AND vctipaportante = 4
            THEN
               vdettiprec := 15;
            ELSIF rebut.ctiprec = 4 AND vctipapor = 6 AND vctipaportante = 4
            THEN
               vdettiprec := 16;
            ELSIF rebut.ctiprec = 4 AND vctipapor = 7 AND vctipaportante = 4
            THEN
               vdettiprec := 17;
            ELSIF rebut.ctiprec = 3 AND vctipapor = 4 AND vctipaportante = 4
            THEN
               vdettiprec := 18;
            ELSIF rebut.ctiprec = 3 AND vctipapor = 1 AND vctipaportante = 1
            THEN
               vdettiprec := 19;
            ELSE
               vdettiprec := NULL;
            END IF;

            IF vdettiprec IS NOT NULL
            THEN
               BEGIN
                  SELECT tatribu
                    INTO rebut.ttiprec
                    FROM detvalores
                   WHERE cvalor = 8
                     AND catribu = vdettiprec
                     AND cidioma = vidioma;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
            END IF;
         END IF;

             --INI SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
             -- Buscamos el recibo de produccion con abono
         --
         -- Inicio IAXIS-4926 23/10/2019
         -- Se comentan las siguientes líneas de código al saberse que no se requieren dichos cambios.
         --
         /*IF rebut.ctiprec IN (1,9) AND rebut.testrec = 'Pendiente' THEN -- Hacemos solo esto para extornos y suplementos cuando sean negativos
           --
           BEGIN
             --
           SELECT sseguro,nmovimi
                  INTO v_sseguro,v_nmovimi
                  FROM recibos
                  WHERE nrecibo = rebut.nrecibo;
              --
            SELECT cmovseg
              INTO v_cmovseg
             FROM movseguro
                    WHERE sseguro = v_sseguro
                     AND nmovimi = v_nmovimi;
             --
             IF v_cmovseg =52 THEN -- Anulacion movimiento
               --
             v_importe_ab := v_sum_importe;
             --
             rebut.importe := rebut.importe + v_importe_ab;
             --
             ELSIF v_cmovseg = 3 THEN -- Anulacion toda la poliza
               --
             rebut.importe := (-1)* (rebut.importe + v_sum_importe);
                     --
             END IF;
             --
           EXCEPTION WHEN OTHERS THEN
                   v_sseguro := 0;
                END;

         END IF;*/
         --
         -- Fin IAXIS-4926 23/10/2019
         --
             --INI SPV IAXIS-4926 Anulación de póliza y movimientos con recibos abonados
         rebut.tdescpag :=
            pac_iax_gestion_rec.f_desctippag (rebut.nrecibo, vidioma,
                                              mensajes);
         /* BUG 29603 -- JDS -- 10/01/2014*/
         rebuts.EXTEND;
         rebuts (rebuts.LAST) := rebut;
         rebut := ob_iax_detrecibo ();
      END LOOP;

      CLOSE cur;

      RETURN rebuts;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      =>    SQLERRM
                                                            || ' '
                                                            || squery
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_recibos;

   /***********************************************************************
      Recupera los movimientos de la póliza
      param in psolicit  : número de solicitud
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_mvtpoliza (psolicit IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor
   IS
      squery     VARCHAR (2000);
      cur        sys_refcursor;
      vidioma    NUMBER         := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'psolicit=' || psolicit;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Get_MvtPoliza';
   BEGIN
      /* Bug 9390 - APD - 26/05/2009 - se añade la condicion nmovimi desc en el ORDER BY*/
      /* Bug 23940 - APD - 17/12/2012 - se a?? el campo cestadocol*/
      /* Bug 25840 - APD - 06/05/2013 -- se debe mirar primero si existe descripcion*/
      /* propia del suplemento (PDS_SUPL_GRUP), sino se debe obtener la descripcion del suplemento*/
      /* de MOTMOVSEG*/
      squery :=
            'select nmovimi,fmovimi,
                            (select tatribu from detvalores where cvalor=16
                              and catribu=cmovseg
                              and cidioma='
         || vidioma
         || ') as ttipmov,
                            (select tmotmov from motmovseg motmov
                              where motmov.CMOTMOV= movseguro.CMOTMOV
                              and cidioma='
         || vidioma
         || ' and not exists(select 1
                                from pds_supl_grup
                                where cempres = '
         || pac_md_common.f_get_cxtempresa ()
         || '
                                  and cmotmov = motmov.cmotmov
                                  and slitera IS NOT NULL)
                          UNION
                            SELECT f_axis_literales(slitera,'
         || vidioma
         || ')
                                from pds_supl_grup
                                where cempres = '
         || pac_md_common.f_get_cxtempresa ()
         || '
                                  and cmotmov = movseguro.CMOTMOV and slitera IS NOT NULL) as tmotmov, '
         || ' fefecto,CMOTMOV, CUSUMOV, femisio,
                            (select tatribu from detvalores where cvalor=1110
                              and catribu=cestadocol
                              and cidioma='
         || vidioma
         || ') as testadocol, '
         || ' (SELECT r.ncertdian FROM rango_dian_movseguro r where r.sseguro = movseguro.sseguro and r.nmovimi = movseguro.nmovimi) ncertdian '
         || '    from movseguro where sseguro='
         || psolicit
         || ' ORDER BY movseguro.fmovimi desc, movseguro.nmovimi desc';
      /* fin Bug 25840 - APD - 06/05/2013*/
      /* fin Bug 23940 - APD - 17/12/2012 - se a?? el campo cestadocol*/
      /* Bug 9390 - APD - 26/05/2009 - fin*/
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_mvtpoliza;

   /*************************************************************************
      Llena el objeto el o los motivos de retención de polizas con la información
      de la póliza seleccionada y movimiento. Si el movimiento es informado con un NULO, retorna
      todos los motivos de retención de la póliza.
      param in psseguro  : código de póliza
      param in pnmovimi  : número del movimiento de la póliza
      param out mensajes : mensajes de error
      return             : objeto motivos retención póliza
   *************************************************************************/
   FUNCTION f_get_motretenmov (
      psseguro   IN       seguros.sseguro%TYPE,
      pnmovimi   IN       motretencion.nmovimi%TYPE,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN t_iax_polmvtreten
   IS
      mvtreten   t_iax_polmvtreten;
      vpasexec   NUMBER (8)        := 1;
      vparam     VARCHAR2 (500)
                   := 'psseguro= ' || psseguro || ' - pnmovimi= ' || pnmovimi;
      vobject    VARCHAR2 (200)    := 'PAC_MD_PRODUCCION.F_Get_MotRetenMov';
      vnumerr    NUMBER (8)        := 0;

      CURSOR cr_motreten (vcr_sseguro NUMBER, vcr_nmovimi VARCHAR2)
      IS
         SELECT   mt.sseguro, mt.nriesgo, mt.nmovimi, mt.cmotret, mt.cusuret,
                  mt.freten, mt.nmotret,
                  NVL (f_nombre (ri.sperson, 1, s.cagente), '') nom,
                  mt.cestgest
             FROM motretencion mt, riesgos ri, seguros s
            WHERE mt.sseguro = vcr_sseguro
              AND mt.nmovimi = NVL (vcr_nmovimi, mt.nmovimi)
              AND ri.sseguro = mt.sseguro
              AND ri.nriesgo = mt.nriesgo
              AND s.sseguro = ri.sseguro
         UNION
         SELECT   mt.sseguro, mt.nriesgo, mt.nmovimi, mt.cmotret, mt.cusuret,
                  mt.freten, mt.nmotret,
                  NVL (f_nombre_est (ri.sperson, 1, s.sseguro), '') nom,
                  mt.cestgest
             FROM estmotretencion mt, estriesgos ri, estseguros s
            WHERE mt.sseguro = vcr_sseguro
              AND mt.nmovimi = NVL (vcr_nmovimi, mt.nmovimi)
              AND ri.sseguro = mt.sseguro
              AND ri.nriesgo = mt.nriesgo
              AND s.sseguro = ri.sseguro
         ORDER BY nmovimi DESC, nmotret DESC, nriesgo;
   BEGIN
      /*Comprovació dels parámetres d'entrada*/
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      FOR c IN cr_motreten (psseguro, pnmovimi)
      LOOP
         IF mvtreten IS NULL
         THEN
            mvtreten := t_iax_polmvtreten ();
         END IF;

         vpasexec := 5;
         mvtreten.EXTEND;
         mvtreten (mvtreten.LAST) := ob_iax_polmvtreten ();
         mvtreten (mvtreten.LAST).sseguro := c.sseguro;
         mvtreten (mvtreten.LAST).nriesgo := c.nriesgo;
         mvtreten (mvtreten.LAST).nmovimi := c.nmovimi;
         mvtreten (mvtreten.LAST).cmotret := c.cmotret;
         mvtreten (mvtreten.LAST).tmotret :=
            pac_iax_listvalores.f_getdescripvalores (708, c.cmotret, mensajes);
         mvtreten (mvtreten.LAST).cusuret := c.cusuret;
         mvtreten (mvtreten.LAST).freten := c.freten;
         vpasexec := 7;
         mvtreten (mvtreten.LAST).triesgo := c.nom;
         vpasexec := 8;
         mvtreten (mvtreten.LAST).nmotret := c.nmotret;
         mvtreten (mvtreten.LAST).cestgest := c.cestgest;
         mvtreten (mvtreten.LAST).testgest :=
            pac_iax_listvalores.f_getdescripvalores (800016,
                                                     c.cestgest,
                                                     mensajes
                                                    );
         vpasexec := 9;
         vnumerr :=
            pac_motretencion.f_get_datosauto
                                            (c.sseguro,
                                             c.nriesgo,
                                             c.nmovimi,
                                             c.cmotret,
                                             c.nmotret,
                                             NULL,
                                             mvtreten (mvtreten.LAST).cusuauto,
                                             mvtreten (mvtreten.LAST).fusuauto,
                                             mvtreten (mvtreten.LAST).cresulta,
                                             mvtreten (mvtreten.LAST).tobserva
                                            );

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN mvtreten;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_motretenmov;

   /***********************************************************************
      Recupera los documentos asociados a un determinado movimiento de la póliza
       param in psseguro   : número del seguro
       param in pnmovimi   : número del movimiento
       param out mensajes  : mensajes de error
       return              : ref cursor
   ***********************************************************************/
   FUNCTION f_get_docmvtpoliza (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vnumerr    NUMBER (8)     := 0;
      squery     VARCHAR (1000);
      cur        sys_refcursor;
      vidioma    NUMBER         := pac_md_common.f_get_cxtidioma;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         := 'parámetros - psseguro: ' || psseguro || ' - pnmovimi: '
            || pnmovimi;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Get_DocMvtPoliza';
   BEGIN
      /*Comprovació dels parámetres d'entrada*/
      IF psseguro IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      squery :=
            ' select d.sseguro, d.nmovimi, d.iddocgedox '
         || ' from docummovseg d '
         || ' where d.sseguro = '
         || psseguro
         || ' and d.nmovimi = '
         || pnmovimi
         || ' order by d.iddocgedox ';
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_docmvtpoliza;

/************************************************************************
                             FI CONSULTA
************************************************************************/
/************************************************************************
                          RETENCIÓN PÓLIZAS
************************************************************************/
/*************************************************************************
   Llena el objeto retención polizas con la información de las retenidas
   param in psproduc  : código de producto
   param in pnpoliza  : número de póliza
   param in pnsolici  : número de solicitud
   param in pncertif  : número de certificado
   param in pnnumide  : número de identificación persona
   param in psnip     : identificador externo de persona
            DEFAULT NULL
   param in pnombre   : texto a buscar como tomador
   param in pcreteni  : situación de la póliza
   param out mensajes : mensajes de error
   return             : 0 todo correcto
                        1 ha habido un error
*************************************************************************/
   FUNCTION f_get_polizasreten (
      pcagente       IN       NUMBER,
      pramo          IN       NUMBER,
      psproduc       IN       NUMBER,
      pnpoliza       IN       NUMBER,
      pnsolici       IN       NUMBER,
      pncertif       IN       NUMBER DEFAULT -1,
      pnnumide       IN       VARCHAR2,
      psnip          IN       VARCHAR2 DEFAULT NULL,
      pnombre        IN       VARCHAR2,
      pcreteni       IN       NUMBER,
      pcmatric       IN       VARCHAR2,            /*BUG19605:LCF:19/02/2010*/
      pcpostal       IN       VARCHAR2,            /*BUG19605:LCF:19/02/2010*/
      ptdomici       IN       VARCHAR2,            /*BUG19605:LCF:19/02/2010*/
      ptnatrie       IN       VARCHAR2,            /*BUG19605:LCF:19/02/2010*/
      p_filtroprod   IN       VARCHAR2,
      mensajes       IN OUT   t_iax_mensajes,
      pcsucursal     IN       NUMBER DEFAULT NULL,
      /* Bug 22839/126886 - 29/10/2012 - AMC*/
      pcadm          IN       NUMBER DEFAULT NULL,
      /* Bug 22839/126886 - 29/10/2012 - AMC*/
      pcmotor        IN       VARCHAR2 DEFAULT NULL,
      /* Bug 25177/133016 - 28/12/2012 - AMC*/
      pcchasis       IN       VARCHAR2 DEFAULT NULL,
      /* Bug 25177/133016 - 28/12/2012 - AMC*/
      pnbastid       IN       VARCHAR2 DEFAULT NULL,
      /* Bug 25177/133016 - 28/12/2012 - AMC*/
      pcpolcia       IN       VARCHAR2 DEFAULT NULL,
      /* Bug 0029965 - 14/04/2014 - FAL*/
      pfretend       IN       DATE DEFAULT NULL,
      /* Bug 0029965 - 14/04/2014 - FAL*/
      pfretenh       IN       DATE DEFAULT NULL,
      /* Bug 0029965 - 14/04/2014 - FAL*/
      pcactivi       IN       NUMBER DEFAULT NULL,
      --CJMR 19/03/2019 IAXIS-3194
      pnnumidease    IN       VARCHAR2 DEFAULT NULL,
      --CJMR 19/03/2019 IAXIS-3194
      pnombrease     IN       VARCHAR2 DEFAULT NULL
   )                                              --CJMR 19/03/2019 IAXIS-3194
      RETURN t_iax_polizasreten
   IS
      cur                 sys_refcursor;
      squery              VARCHAR2 (4000);
      /* Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación*/
      /*                                se añade la subselect con la tabla agentes_agente*/
      /* Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol*/
      buscar              VARCHAR2 (4000)
         := ' WHERE (s.cagente,s.cempres) IN (SELECT cagente,cempres FROM agentes_agente_pol) ';
      /* Bug 10127 - APD - 19/05/2009 - fin*/
      vform               VARCHAR2 (4000)    := '';
      subus               VARCHAR2 (4000);
      tabtp               VARCHAR2 (10);
      auxnom              VARCHAR2 (200);
      nerr                NUMBER;
      reten               t_iax_polizasreten;
      segsseguro          NUMBER;
      segnmovimi          NUMBER;
      segnsuplem          NUMBER;
      segnpoliza          NUMBER;
      segnsolici          NUMBER;
      segncertif          NUMBER;
      segsproduc          NUMBER;
      segfefecto          DATE;
      segfemisio          DATE;
      segcsituac          NUMBER;
      segcreteni          NUMBER;
      segfmovimi          DATE;
      segcramo            NUMBER (8);
      segcmodali          NUMBER (2);
      segctipseg          NUMBER (2);
      segccolect          NUMBER (2);
      segcusumov          VARCHAR2 (20);
      -- Ini IAXIS-3504 -- ECP -- 18/12/2019
      segcmotmov          NUMBER;
      segtmotmov          VARCHAR2 (100);
      -- Fin IAXIS-3504 -- ECP -- 18/12/2019
                                     /* Bug 24353/127268 - 26/10/2012 - AMC*/
      vcidioma            NUMBER;
      vcempres            NUMBER;
      vpasexec            NUMBER (8)         := 1;
      v_sentence          VARCHAR2 (2000);
      vparam              VARCHAR2 (500)
         :=    'psproduc= '
            || psproduc
            || ' pnpoliza= '
            || pnpoliza
            || ' pnsolici= '
            || pnsolici
            || ' pncertif='
            || pncertif
            || ' pcpostal='
            || pcpostal
            || ' psnip='
            || psnip
            || ' pcmatric='
            || pcmatric
            || ' pnnumide='
            || pnnumide
            || ' ptdomici='
            || ptdomici
            || 'ptnatrie='
            || ptnatrie
            || ' pnombre='
            || pnombre
            || ' pcreteni='
            || pcreteni;
      vobject             VARCHAR2 (200)
                                     := 'PAC_MD_PRODUCCION.F_Get_PolizasReten';
      v_max_reg           NUMBER;     /* número mÃ xim de registres mostrats*/
      vnnumide            VARCHAR2 (100);
      /* BUG 38344/217178 - 09/11/2015 - ACL*/
      vsnip               VARCHAR2 (100);
      /* BUG 38344/217178 - 09/11/2015 - ACL*/
      ret_subestadoprop   NUMBER;                    --CONF-249-30/11/2016-RCS
      v_subestadoprop     VARCHAR2 (80);             --CONF-249-30/11/2016-RCS
   BEGIN
      vpasexec := 1;
      /* dra 27-10-2008: bug mantis 7519*/
      /* jlb 06/04/2011: bug mantis 18181*/
      buscar :=
            buscar
         || ' AND m.sseguro = s.sseguro
                     AND m.nmovimi IN (SELECT MAX (m2.nmovimi)
                                         FROM movseguro m2
                                        WHERE m2.sseguro = s.sseguro)
                     AND s.csituac IN (4, 5, 12)
                     AND (s.creteni IN (0, 2, 5,7,9)
                          OR (s.creteni = 1
                              AND ((EXISTS (
                                   SELECT mot.cmotret
                                     FROM motretencion mot
                                    WHERE mot.sseguro = s.sseguro
                                      AND mot.nmovimi = m.nmovimi
                                      AND mot.cmotret IN (1, 4, 5, 6, 10,20)))
                                OR ( EXISTS(SELECT pp.cmotret
                                              FROM psu_retenidas pp
                                             WHERE pp.sseguro = s.sseguro
                                               AND pp.nmovimi = m.nmovimi ) ) ) )
                          OR (s.creteni IN (3, 4) AND '
         || NVL (pcreteni, 0)
         || ' IN (3, 4) ) ) ';

      /*xpl, 0010270: Añadir filtro de agente y ramo a buscadores*/
      IF NVL (psproduc, 0) <> 0
      THEN
         buscar := buscar || ' AND s.sproduc =' || psproduc;
      ELSE
         nerr := pac_productos.f_get_filtroprod (p_filtroprod, v_sentence);

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         IF v_sentence IS NOT NULL
         THEN
            buscar :=
                  buscar
               || ' AND s.sproduc IN (SELECT p.sproduc FROM productos p WHERE'
               || v_sentence
               || ' 1=1)';
         END IF;

         IF pramo IS NOT NULL
         THEN
            buscar :=
                  buscar
               || ' AND s.sproduc IN (SELECT p.sproduc FROM productos p WHERE'
               || ' p.cramo = '
               || pramo
               || ' )';
         END IF;
      END IF;

      IF pcagente IS NOT NULL
      THEN
         buscar := buscar || ' AND s.cagente = ' || pcagente;
      END IF;

      IF pnpoliza IS NOT NULL
      THEN
         buscar :=
             buscar || ' AND s.npoliza = ' || CHR (39) || pnpoliza
             || CHR (39);
      END IF;

      /* BUG5673:dra:11-02-2009*/
      IF pnsolici IS NOT NULL
      THEN
         buscar :=
             buscar || ' AND s.nsolici = ' || CHR (39) || pnsolici
             || CHR (39);
      END IF;

      IF NVL (pncertif, -1) <> -1
      THEN
         buscar := buscar || ' AND s.ncertif = ' || pncertif;
      END IF;

      IF NVL (pcreteni, -1) <> -1
      THEN
         buscar := buscar || ' AND s.creteni = ' || pcreteni;
      END IF;

      -- INI CJMR 19/03/2019 IAXIS-3194
      IF pcactivi IS NOT NULL
      THEN
         buscar := buscar || ' AND s.cactivi=' || pcactivi;
      END IF;

      -- FIN CJMR 19/03/2019 IAXIS-3194

      /* Bug 0029965 - 14/04/2014 - FAL*/
      IF pcpolcia IS NOT NULL
      THEN
         buscar := buscar || ' and s.cpolcia=' || '''' || pcpolcia || '''';
      END IF;

      IF pfretend IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in ( select mot.sseguro'
            || ' from motretencion  mot'
            || ' where mot.freten >= TO_DATE('''
            || TO_CHAR (pfretend, 'DDMMYYYY')
            || ''',''DDMMYYYY''))';
      END IF;

      IF pfretenh IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in ( select mot.sseguro'
            || ' from motretencion  mot'
            || ' where mot.freten <= TO_DATE('''
            || TO_CHAR (pfretenh, 'DDMMYYYY')
            || ''',''DDMMYYYY''))';
      END IF;

      /* Fi Bug 0029965 - 14/04/2014 - FAL*/
      /* BUG19605:LCF:19/02/2010:inici*/
      IF pcmatric IS NOT NULL
      THEN
         vform := ' , autriesgos aut ';
         buscar :=
               buscar
            || ' AND aut.sseguro = s.sseguro AND UPPER(aut.cmatric) LIKE UPPER(''%'
            || pcmatric
            || '%'') AND aut.nmovimi = (SELECT MAX(nmovimi) FROM movseguro WHERE sseguro = s.sseguro)';
      /* FAL - 03/11/2011 - 0020008: Consulta Pólizas Autos devuelve más de un registro*/
      END IF;

      /* Bug 25177/133016 - 28/12/2012 - AMC*/
      IF pcmotor IS NOT NULL
      THEN
         IF vform IS NULL
         THEN
            vform := ' , autriesgos aut ';
            buscar :=
                  buscar
               || ' AND aut.sseguro = s.sseguro '
               || ' AND aut.nmovimi = (SELECT MAX(nmovimi) FROM movseguro WHERE sseguro = s.sseguro) ';
         END IF;

         buscar :=
               buscar
            || ' AND UPPER(aut.codmotor) LIKE UPPER(''%'
            || pcmotor
            || '%'') ';
      END IF;

      IF pcchasis IS NOT NULL
      THEN
         IF vform IS NULL
         THEN
            vform := ' , autriesgos aut ';
            buscar :=
                  buscar
               || ' AND aut.sseguro = s.sseguro '
               || ' AND aut.nmovimi = (SELECT MAX(nmovimi) FROM movseguro WHERE sseguro = s.sseguro) ';
         END IF;

         buscar :=
               buscar
            || ' AND UPPER(aut.cchasis) LIKE UPPER(''%'
            || pcchasis
            || '%'') ';
      END IF;

      IF pnbastid IS NOT NULL
      THEN
         IF vform IS NULL
         THEN
            vform := ' , autriesgos aut ';
            buscar :=
                  buscar
               || ' AND aut.sseguro = s.sseguro '
               || ' AND aut.nmovimi = (SELECT MAX(nmovimi) FROM movseguro WHERE sseguro = s.sseguro) ';
         END IF;

         buscar :=
               buscar
            || ' AND UPPER(aut.nbastid) LIKE UPPER(''%'
            || pnbastid
            || '%'') ';
      END IF;

      /* Fi Bug 25177/133016 - 28/12/2012 - AMC*/
      IF pcpostal IS NOT NULL OR ptdomici IS NOT NULL
      THEN
         vform := vform || ' , sitriesgo sit ';
      END IF;

      IF pcpostal IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' AND sit.sseguro = s.sseguro AND UPPER(sit.cpostal) LIKE UPPER(''%'
            || pcpostal
            || '%'')';
      END IF;

      IF ptdomici IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' AND sit.sseguro = s.sseguro AND UPPER(sit.tdomici) LIKE UPPER(''%'
            || ptdomici
            || '%'')';
      END IF;

      IF ptnatrie IS NOT NULL
      THEN
         vform := vform || ' , riesgos rie ';
         buscar :=
               buscar
            || ' AND rie.sseguro = s.sseguro AND UPPER(rie.tnatrie) LIKE UPPER(''%'
            || ptnatrie
            || '%'')';
      END IF;

      /* Bug 22839/126886 - 29/10/2012 - AMC*/
      IF pcsucursal IS NOT NULL OR pcadm IS NOT NULL
      THEN
         vform := vform || ' ,seguredcom src ';
         buscar := buscar || ' AND s.sseguro = src.sseguro ';

         IF pcsucursal IS NOT NULL
         THEN
            buscar := buscar || ' AND src.c02 = ' || pcsucursal;
         END IF;

         IF pcadm IS NOT NULL
         THEN
            buscar := buscar || ' AND src.c03 = ' || pcadm;
         END IF;
      END IF;

      /* Fi Bug 22839/126886 - 29/10/2012 - AMC*/
      /* BUG19605:LCF:19/02/2010:fi*/
      vpasexec := 3;

      /*Inici BUG 0027048/160931 - 10/12/2013 - RCL*/
      IF p_filtroprod IS NOT NULL AND p_filtroprod = 'EMISION_MASIVA'
      THEN
         /*La Emisión Masiva, es para pólizas Agrupadas*/
         buscar :=
                buscar || ' AND (pac_seguros.f_es_col_agrup (s.sseguro) = 1 ';
      --BUG 0027048/162274 - 07/01/2014 - RCL
      ELSE
         /*inici bug 26070 / 139455 JDS - 04/03/2013*/
         buscar :=
               buscar
            || ' AND (pac_seguros.f_es_col_admin (s.sseguro) = 0 OR '
            || '(pac_seguros.f_es_col_admin (s.sseguro) = 1 AND '
            /*BUG 34615 DCT 10-06-2015*/
            /* || ' ((m.femisio IS NULL AND pac_seguros.f_get_escertifcero (NULL, s.sseguro) <> 1) '*/
            || ' ((m.femisio IS NULL AND (pac_seguros.f_get_escertifcero (NULL, s.sseguro) <> 1 OR (pac_seguros.f_get_escertifcero (NULL, s.sseguro) = 1 AND s.csituac in (4, 12)))) '
            || ' OR s.creteni = 1))';
      /*fi bug 26070 / 139455 JDS - 04/03/2013*/
      END IF;

      /*Fi BUG 27048/160931 - 10/12/2013 - RCL*/
      IF p_filtroprod IS NOT NULL AND p_filtroprod = 'EMISION_MASIVA'
      THEN
         /*BUG 27048/161690 - 19/12/2013 - RCL - En la emisión masiva no se muestran los certificados 0*/
         buscar := buscar || ')';
      ELSE
         /* Bug 22839 - RSC - 20/11/2012 - LCOL - Funcionalidad Certificado 0*/
         buscar :=
               buscar
            || ' OR (pac_seguros.f_es_col_admin (s.sseguro) = 1 AND '
            || ' ((TRUNC(m.femisio) IS NULL AND pac_seguros.f_get_escertifcero (NULL, s.sseguro) = 1 '
            || ' AND m.cmotmov <> 100 AND NVL(m.cmotven, 0) <> 998)'
            || '   OR s.creteni = 1)))';
      /* Fin bug 22839*/
      END IF;

      /*BUG 29358/162591 - 09/01/2014 - RCL*/
      IF p_filtroprod IS NOT NULL AND p_filtroprod = 'EMISION_MASIVA'
      THEN
         /*RCL BUG 27048/158857 - 22/11/2013 - Emision masiva*/
         buscar :=
               buscar
            || ' and s.sseguro not in (select em.sseguro from emision_masiva em where em.sseguro = s.sseguro and em.cestado in (1, 3))';
      END IF;

      /* buscar per personas*/
      /* FIN CJMR 27/03/2019
      IF (pnnumide IS NOT NULL OR NVL(psnip, ' ') <> ' ' OR
         pnombre IS NOT NULL)
      THEN
         tabtp := 'TOMADORES';  -- Prenador

         IF tabtp IS NOT NULL
         THEN
            subus := ' AND s.sseguro IN (SELECT a.sseguro FROM ' || tabtp ||
                     ' a, personas p WHERE a.sperson = p.sperson';

            IF pnnumide IS NOT NULL
            THEN
               vnnumide := pnnumide;

               vnnumide := REPLACE(vnnumide, chr(39), chr(39) || chr(39));

               subus := subus || ' AND UPPER(p.nnumnif) = UPPER(' ||
                        chr(39) || vnnumide || chr(39) || ')';
            END IF;

            IF NVL(psnip, ' ') <> ' '
            THEN
               vsnip := psnip;

               vsnip := REPLACE(vsnip, chr(39), chr(39) || chr(39));

               subus := subus || ' AND UPPER(p.snip) = UPPER(' || chr(39) ||
                        vsnip || chr(39) || ')';
            END IF;

            IF pnombre IS NOT NULL
            THEN
               nerr := f_strstd(pnombre, auxnom);

               subus := subus || ' AND UPPER(p.tbuscar) LIKE UPPER(''%' ||
                        auxnom || '%' || chr(39) || ')';
            END IF;

            subus := subus || ')';
         END IF;
      END IF;
      FIN CJMR 27/03/2019 */

      -- INI CJMR 19/03/2019 IAXIS-3194
      -- Número de identificación y/o nombre del tomador
      IF pnnumide IS NOT NULL OR pnombre IS NOT NULL
      THEN
         subus :=
               subus
            || ' AND s.sseguro IN (SELECT a.sseguro FROM tomadores a, '
            || ' per_personas pp, per_detper pdp WHERE a.sperson = pp.sperson '
            || ' AND a.sperson = pdp.sperson '
            || ' AND pdp.cagente = ff_agente_cpervisio (s.cagente, f_sysdate, s.cempres)';

         IF pnnumide IS NOT NULL
         THEN
            IF NVL
                  (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NIF_MINUSCULAS'
                                           ),
                   0
                  ) = 1
            THEN
               subus :=
                     subus
                  || ' AND UPPER(pp.nnumide) = UPPER('
                  || CHR (39)
                  || ff_strstd (pnnumide)
                  || CHR (39)
                  || ')';
            ELSE
               subus :=
                     subus
                  || ' AND pp.nnumide LIKE '
                  || CHR (39)
                  || '%'
                  || ff_strstd (pnnumide)
                  || '%'
                  || CHR (39)
                  || '';
            END IF;
         END IF;

         IF pnombre IS NOT NULL
         THEN
            nerr := f_strstd (pnombre, auxnom);
            subus :=
                  subus
               || ' AND UPPER ( REPLACE ( pdp.tbuscar, '
               || CHR (39)
               || '  '
               || CHR (39)
               || ','
               || CHR (39)
               || ' '
               || CHR (39)
               || ' )) LIKE UPPER(''%'
               || auxnom
               || '%'
               || CHR (39)
               || ')';
         END IF;

         subus := subus || ')';
      END IF;

      -- Numero de identificacion y/o nombre del asegurado
      IF pnnumidease IS NOT NULL OR pnombrease IS NOT NULL
      THEN
         subus :=
               subus
            || ' AND s.sseguro IN (SELECT a.sseguro FROM asegurados a, '
            || ' per_personas pp, per_detper pdp WHERE a.sperson = pp.sperson '
            || ' AND a.sperson = pdp.sperson '
            || ' AND pdp.cagente = ff_agente_cpervisio (s.cagente, f_sysdate, s.cempres)'
            || ' AND a.ffecfin IS NULL';

         IF pnnumidease IS NOT NULL
         THEN
            IF NVL
                  (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NIF_MINUSCULAS'
                                           ),
                   0
                  ) = 1
            THEN
               subus :=
                     subus
                  || ' AND UPPER(pp.nnumide) = UPPER('
                  || CHR (39)
                  || ff_strstd (pnnumidease)
                  || CHR (39)
                  || ')';
            ELSE
               subus :=
                     subus
                  || ' AND pp.nnumide LIKE '
                  || CHR (39)
                  || '%'
                  || ff_strstd (pnnumidease)
                  || '%'
                  || CHR (39)
                  || '';
            END IF;
         END IF;

         IF pnombrease IS NOT NULL
         THEN
            nerr := f_strstd (pnombrease, auxnom);
            subus :=
                  subus
               || ' AND UPPER ( REPLACE ( pdp.tbuscar, '
               || CHR (39)
               || '  '
               || CHR (39)
               || ','
               || CHR (39)
               || ' '
               || CHR (39)
               || ' )) LIKE UPPER(''%'
               || auxnom
               || '%'
               || CHR (39)
               || ')';
         END IF;

         subus := subus || ')';
      END IF;

      -- FIN CJMR 19/03/2019 IAXIS-3194
      vpasexec := 5;
      /* Bug 24353/127268 - 26/10/2012 - AMC*/
      squery :=
            'SELECT s.sseguro, s.npoliza, s.nsolici, s.ncertif, '
         || ' s.sproduc, s.fefecto, s.femisio, s.csituac, '
         || ' s.creteni, s.nsuplem, m.fmovimi, m.nmovimi, '
         || ' s.cramo, s.cmodali, s.ctipseg, s.ccolect, m.cusumov '
         -- Ini IAXIS-3504--ECP -- 09/09/2019
         || ' , m.cmotmov , (select tmotmov from motmovseg where cmotmov  = m.cmotmov and cidioma = '
         || pac_md_common.f_get_cxtidioma
         || ') tmotmov '                -- Bug 22839/125653 - 26/10/2010 - AMC
         -- Fin IAXIS-3504--ECP -- 09/09/2019
         || ' FROM seguros s, movseguro m '
         || vform
         || buscar
         || subus
         || ' ORDER BY s.npoliza, s.ncertif';
      /* Fi Bug 24353/127268 - 26/10/2012 - AMC*/
      vpasexec := 6;
      /* BUG10127:DRA:19/05/2009:Inici*/
      v_max_reg := pac_parametros.f_parinstalacion_n ('N_MAX_REG');

      /*  IF v_max_reg IS NOT NULL THEN
         IF INSTR(squery, 'ORDER BY', -1, 1) > 0 THEN
            -- se hace de esta manera para mantener el orden de los registros
            squery := 'SELECT * FROM (' || squery || ') WHERE ROWNUM <= ' || v_max_reg;
         ELSE
            squery := squery || ' AND ROWNUM <= ' || v_max_reg;
         END IF;
      END IF;*/
      /*Bug 27048/155982 - JSV - 18/10/2013*/
      IF pnpoliza IS NULL AND pnsolici IS NULL
      THEN
         IF v_max_reg IS NOT NULL
         THEN
            IF INSTR (squery, 'ORDER BY', -1, 1) > 0
            THEN
               /* se hace de esta manera para mantener el orden de los registros*/
               squery :=
                     'SELECT * FROM ('
                  || squery
                  || ') WHERE ROWNUM <= '
                  || v_max_reg;
            ELSE
               squery := squery || ' AND ROWNUM <= ' || v_max_reg;
            END IF;
         END IF;
      END IF;

      /* BUG10127:DRA:19/05/2009:Fi*/
      vpasexec := 7;
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
      vpasexec := 8;
      /* IF cur%rowcount=0 THEN*/
      /*    PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,2,3232,'No se ha localizado ninguna póliza que cumpla los criterios indicados');*/
      /*    RETURN NULL;*/
      /* END IF;*/
      reten := t_iax_polizasreten ();
      vpasexec := 9;
      vcidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 10;

      LOOP
         FETCH cur
          INTO segsseguro, segnpoliza, segnsolici, segncertif, segsproduc,
               segfefecto, segfemisio, segcsituac, segcreteni, segnsuplem,
               segfmovimi, segnmovimi, segcramo, segcmodali, segctipseg,
               segccolect, segcusumov, segcmotmov, segtmotmov;

         /* Bug 24353/127268 - 26/10/2012 - AMC*/
         EXIT WHEN cur%NOTFOUND;
         vpasexec := 11;
         reten.EXTEND;
         reten (reten.LAST) := ob_iax_polizasreten ();
         reten (reten.LAST).sseguro := segsseguro;
         reten (reten.LAST).nmovimi := segnmovimi;
         reten (reten.LAST).nsuplem := segnsuplem;
         reten (reten.LAST).npoliza := segnpoliza;
         reten (reten.LAST).nsolici := segnsolici; /* BUG5673:dra:11-2-2009*/
         reten (reten.LAST).ncertif := segncertif;
         reten (reten.LAST).sproduc := segsproduc;
         reten (reten.LAST).fefecto := segfefecto;
         reten (reten.LAST).femisio := segfemisio;
         reten (reten.LAST).nnumide :=
                      pac_iax_listvalores.f_get_numidetomador (segsseguro, 1);
         reten (reten.LAST).tomador :=
                        pac_iax_listvalores.f_get_nametomador (segsseguro, 1);
         reten (reten.LAST).csituac := segcsituac;
         reten (reten.LAST).tsituac :=
                       pac_iax_listvalores.f_get_situacionpoliza (segsseguro);
         reten (reten.LAST).creteni := segcreteni;
         --RET_SUBESTADOPROP := PAC_PSU.F_GET_SUBESTADOPROP(SEGSSEGURO,V_SUBESTADOPROP); --CONF-249-30/11/2016-RCS
         reten (reten.LAST).treteni :=
               v_subestadoprop
            || '/'
            || pac_iax_listvalores.f_get_retencionpoliza (segcreteni);
         --CONF-249-30/11/2016-RCS
         reten (reten.LAST).cusumov := segcusumov;
         /* Bug 24353/127268 - 26/10/2012 - AMC*/
         vpasexec := 12;
         -- Ini IAXIS-3504--ECP -- 09/09/2019
         reten (reten.LAST).cmotmov := segcmotmov;
         reten (reten.LAST).tmotmov := segtmotmov;
         -- Fin IAXIS-3504--ECP -- 09/09/2019
         nerr :=
            f_desproducto (segcramo,
                           segcmodali,
                           2,
                           vcidioma,
                           reten (reten.LAST).trotulo,
                           segctipseg,
                           segccolect
                          );

         IF nerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 13;
         nerr :=
            pac_seguros.f_get_nsolici_npoliza (segsseguro,
                                               NULL,
                                               segsproduc,
                                               segcsituac,
                                               segnsolici,
                                               segnpoliza,
                                               segncertif
                                              );

         IF nerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
            RAISE e_object_error;
         END IF;

         /* BUG5673:dra:11-2-2009*/
         reten (reten.LAST).npoliza := segnpoliza;
         reten (reten.LAST).nsolici := segnsolici;
         vpasexec := 14;
         /*-- Permetem que l'usuari editi una pólissa si ás ell mateix que hi ha retingut la pólissa manualment
         SELECT DECODE(COUNT('x'), 0, 0, 1)
           INTO reten(reten.LAST).cedit
           FROM motretencion mt
          WHERE mt.sseguro = segsseguro
            AND mt.nmovimi = segnmovimi
            AND mt.cmotret = 1
            AND mt.cusuret = f_user;*/
         /*BUG 10090 - 26/05/2009 - APR - Modificación de polizas de otros usuarios*/
         vcempres := pac_md_common.f_get_cxtempresa;
         nerr :=
            pac_motretencion.f_editar_propuesta (segsseguro,
                                                 segnmovimi,
                                                 vcempres,
                                                 f_user,
                                                 reten (reten.LAST).cedit
                                                );

         IF nerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

      CLOSE cur;

      IF pac_md_log.f_log_consultas (squery,
                                     'PAC_MD_PRODUCCION.F_GET_POLIZASRETEN',
                                     1,
                                     2,
                                     mensajes
                                    ) <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN reten;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_polizasreten;

   /*************************************************************************
      Valida si se puede anular una propuesta de póliza retenida
      param in psseguro  : código de póliza
      param in pcreteni  : propuesta retenida
      param out mensajes : mensajes de error
      return             : 0 -> No se puede anular la propuesta
                           1 -> Si se permite anular la propuesta
   *************************************************************************/
   FUNCTION f_permite_anularpropuesta (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,                 /* BUG10464:DRA:16/06/2009*/
      pcreteni   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr        NUMBER (8);
      vcreteni       NUMBER;
      vpasexec       NUMBER (8)     := 1;
      vparam         VARCHAR2 (500) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2 (200)
                             := 'PAC_MD_PRODUCCION.F_Permite_AnularPropuesta';
      vsperson       NUMBER;
      vcclalis       NUMBER         := 2;
      vctiplis       NUMBER         := 52;
      vsperlre_out   NUMBER;
      vsperlre       NUMBER;
      existe         NUMBER;
   BEGIN
      /*Proposta retinguda => Abans d'anul lar-la comprovem que hagi estat revisada*/
      FOR cr IN (SELECT m.nmovimi, m.nriesgo, m.cmotret
                   FROM motretencion m
                  WHERE m.sseguro = psseguro
                    AND m.nmovimi = pnmovimi      /* BUG10464:DRA:16/06/2009*/
                    AND NOT (pcreteni = 1
                                         /* BUG9296:DRA:09-03-2009: Incloem el cmotret = 4*/
                             AND m.cmotret IN (1, 4, 6))
                                                        /* No es tracta d'una retenció voluntaria.*/
               )
      LOOP
         /*Comprobem que la retenció hagi estat autoritzada.*/
         vnumerr :=
            pac_motretencion.f_risc_retingut (psseguro,
                                              cr.nmovimi,
                                              cr.nriesgo,
                                              cr.cmotret
                                             );

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151435);
            RETURN 0;
         END IF;
      END LOOP;

      IF NVL
            (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                            'INS_LRE_ANULA_PROP'
                                           ),
             0
            ) = 1
      THEN
         SELECT sperson
           INTO vsperson
           FROM tomadores
          WHERE sseguro = psseguro;

         SELECT COUNT (1)
           INTO existe
           FROM lre_personas
          WHERE sperson = vsperson;

         IF existe > 0
         THEN
            SELECT sperlre
              INTO vsperlre
              FROM lre_personas
             WHERE sperson = vsperson;

            vnumerr :=
               pac_listarestringida.f_set_listarestringida (vsperson,
                                                            vcclalis,
                                                            vctiplis,
                                                            NULL,
                                                            vsperlre_out,
                                                            vsperlre,
                                                            NULL,
                                                            f_sysdate,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL
                                                           );
         ELSE
            vnumerr :=
               pac_listarestringida.f_set_listarestringida (vsperson,
                                                            vcclalis,
                                                            vctiplis,
                                                            NULL,
                                                            vsperlre_out,
                                                            NULL,
                                                            NULL,
                                                            f_sysdate,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL
                                                           );
         END IF;

         IF vnumerr > 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151435);
         END IF;
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_permite_anularpropuesta;

   /*************************************************************************
      Anula la propuesta de póliza retenida
      param in psseguro  : código de póliza
      param in pnsuplem  : Contador del número de suplementos
      param in pcmotmov  : código motivo de movimiento
      param in ptobserva : observaciones
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido errores
   *************************************************************************/
   FUNCTION f_anularpropuesta (
      psseguro    IN       NUMBER,
      pnsuplem    IN       NUMBER,
      pcmotmov    IN       NUMBER,
      ptobserva   IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr       NUMBER (8);
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'parámetros - psseguro: '
            || psseguro
            || ' - pnsuplem: '
            || pnsuplem
            || ' - pcmotmov: '
            || pcmotmov;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_AnularPropuesta';
   BEGIN
      /*Comprovació de parÃ metres d'entrada*/
      IF psseguro IS NULL OR pnsuplem IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pcmotmov IS NULL
      THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 140998);
         RETURN 1;
      END IF;

      vpasexec := 3;
      nerr :=
         pk_rechazo_movimiento.f_rechazo (psseguro,
                                          pcmotmov,
                                          pnsuplem,
                                          4,
                                          ptobserva
                                         );

      IF nerr <> 0
      THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerr);
         RETURN 1;
      ELSE
         COMMIT;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 700341);
      END IF;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_anularpropuesta;

   /*************************************************************************
      Emitir la propuesta de póliza retenida
      param in  psseguro : código de póliza
      param in  pnmovimi : número de movimiento
      param out onpoliza : número de pólissa assignat a la proposta emessa
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido errores
   *************************************************************************/
   FUNCTION f_emitirpropuesta (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      onpoliza   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes,
      psproces   IN       NUMBER DEFAULT NULL
   )                                              /* BUG23853:DRA:08/11/2012*/
      RETURN NUMBER
   IS
      vnumerr          NUMBER (8);
      vterror          VARCHAR2 (1000);
      vcreteni         NUMBER;
      vvsseguro        NUMBER;
      vcempres         NUMBER;
      vnpoliza         NUMBER;
      vncertif         NUMBER;
      vcramo           NUMBER;
      vcmodali         NUMBER;
      vctipseg         NUMBER;
      vccolect         NUMBER;
      vcactivi         NUMBER;
      vcidioma         NUMBER;
      vsproduc         seguros.sproduc%TYPE;
      vttext           VARCHAR2 (1000);
      indice           NUMBER (8);
      indice_e         NUMBER (8);
      v_cmotret        NUMBER (8);
      vtmsg            VARCHAR2 (500);
      vpasexec         NUMBER (8)             := 1;
      vparam           VARCHAR2 (200)
         :=    'psseguro: '
            || psseguro
            || ' - pnmovimi: '
            || pnmovimi
            || ' - onpoliza: '
            || onpoliza;
      vobject          VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_EmitirPropuesta';
      v_tipo_fefecto   VARCHAR2 (2);
      v_csituac        NUMBER (2);
      v_nmovimi        NUMBER (4);                 /* BUG9329:DRA:09/06/2009*/
      vcont            NUMBER;
      vfefecto         DATE;
      vvigdias         NUMBER;
      /* Bug 0026975 - dlF - 31-III-2014 - Problemas con las fechas de entrada en vigor*/
      dfefecto         seguros.fefecto%TYPE;
      -- Inicio IAXIS-5274 12/02/2020
      rie              ob_iax_riesgos;
      pri              ob_iax_primas;

      -- Fin IAXIS-5274 12/02/2020

      /* fin Bug 0026975 - dlF - 31-III-2014*/
      /* Fin Bug 8745*/
      CURSOR c_rie (pcsseguro IN seguros.sseguro%TYPE, pctablas IN VARCHAR2)
      IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = pcsseguro AND pctablas IS NULL
         UNION ALL
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = pcsseguro AND pctablas = 'EST';

      vparampsu        NUMBER;
      vcmotret         NUMBER;
      /* BUG 27642 - FAL - 24/04/2014*/
      pmensaje         VARCHAR2 (500);
   /* v_existe       NUMBER;*/
   /* n_nmotret      NUMBER;*/
   /* FI BUG 27642*/
   BEGIN
      /*Comprovació de parÃ metres d'entrada*/
      IF psseguro IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*Comprovem l'estat en que es troba la proposta*/
      vnumerr := pac_gestion_retenidas.f_estado_propuesta (psseguro, vcreteni);

      IF vnumerr <> 0
      THEN
         /*Error recuperant el tipus de retenció de la pólissa.*/
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;

      /*Actuem segons l'estat de la proposta*/
      IF vcreteni = 2
      THEN
         /*Proposta pendent d'autorització => No es pot emetre la proposta.*/
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 140598);
         RAISE e_object_error;
      ELSIF vcreteni IN (3, 4)
      THEN
         /*Proposta anulada o rebutjada => No es pot emetre la proposta.*/
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151177);
         RAISE e_object_error;
      ELSIF vcreteni = 1
      THEN
         vpasexec := 5;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         vparampsu := pac_parametros.f_parproducto_n (vsproduc, 'PSU');

         IF NVL (vparampsu, 0) = 0
         THEN
            /*Proposta retinguda => Abans d'emetre-la comprovem que no tingui errors en l'emissió*/
            FOR cr IN c_rie (psseguro, NULL)
            LOOP
               vnumerr :=
                  pac_motretencion.f_risc_retingut (psseguro,
                                                    pnmovimi,
                                                    NVL (cr.nriesgo, 1),
                                                    5
                                                   );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151237);
                  RAISE e_object_error;
               END IF;
            END LOOP;

            vpasexec := 7;
            /*Com que es tractava d'una retenció voluntaria, l'acceptem.*/
            vttext := f_axis_literales (151726, pac_md_common.f_get_cxtidioma);
            vnumerr :=
                    pac_motretencion.f_desretener (psseguro, pnmovimi, vttext);

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         ELSE
            /* BEGIN
               SELECT cmotret
                 INTO vcmotret
                 FROM psu_retenidas
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcmotret := 0;   --si no tá psu ás que no ha saltat res, per tant deixem emetre
            END;


            IF vcmotret <> 0 THEN*/
            /* Bug 28455/156597 - JSV - 22/10/2013 - INI*/
            /*pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000129);*/
            /*RAISE e_object_error;*/
            SELECT COUNT (1)
              INTO vcont
              FROM psu_retenidas pr, psucontrolseg ps
             WHERE pr.sseguro = psseguro
               AND pr.sseguro = ps.sseguro
               AND pr.nmovimi = ps.nmovimi
               AND pr.nmovimi = pnmovimi;

            IF vcont < 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000129);
               RAISE e_object_error;
            ELSE
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9906170);
               RAISE e_object_error;
            END IF;
         /* Bug 28455/156597 - JSV - 22/10/2013 - FIN*/
         /* END IF; No deixem emetre mai si la pólissa es creteni = 1*/
         END IF;
      END IF;

      vpasexec := 9;

      /*Obtenim les dades reals necesaries per emetre*/
      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg,
             ccolect, cactivi, cidioma, sproduc, csituac, fefecto
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg,
             vccolect, vcactivi, vcidioma, vsproduc, v_csituac, vfefecto
        FROM seguros
       WHERE sseguro = psseguro;

      /* Bug 25148 - RSC 10/01/2013 - LCOL - QT 5643*/
      onpoliza := vnpoliza;
      /* Fin Bug 25148*/
      vpasexec := 10;
      /* BUG 7701 - 3/2/2009 - DRA - Posiblemente se quiera poner la fecha de*/
      /* efecto del dÃ­a en que se emite la póliza*/
      /* Se recupera la fecha de efecto*/
      v_tipo_fefecto :=
                    NVL (f_parproductos_v (vsproduc, 'FEFECTO_PROP_RETEN'), 0);

      /* Bug 30779 - dlF - 15-IV-2014 - Problemas al emitir pólizas autorizadas previamente*/
      IF v_tipo_fefecto IN (3, 4) AND v_csituac = 4
      THEN
         /* fin Bug 30779 - dlF - 15-IV-2014*/
         /* Bug 0026975 - dlF - 31-III-2014 - Problemas con las fechas de entrada en vigor*/
         dfefecto := vfefecto;
         vnumerr :=
            f_cambia_f_efecto (psseguro,
                               pnmovimi,
                               vsproduc,
                               dfefecto,
                               TRUNC (f_sysdate)
                              );

         /* fin Bug 0026975 - dlF - 31-III-2014*/
         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         IF v_csituac = 4
         THEN
            vnumerr :=
               pac_cfg.f_get_user_accion_permitida
                                          (pac_md_common.f_get_cxtusuario (),
                                           'VIGENCIA_PROPUESTA',
                                           vsproduc,
                                           pac_md_common.f_get_cxtempresa (),
                                           vvigdias
                                          );

            IF vvigdias > 0
            THEN
               IF NVL
                     (pac_propio.f_psu_retroactividad
                                           (pac_md_common.f_get_cxtempresa (),
                                            psseguro,
                                            pnmovimi
                                           ),
                      0
                     ) = 0
               THEN
                  IF TRUNC (f_sysdate) - TRUNC (vfefecto) > vvigdias
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           9906448
                                                          );
                     ROLLBACK;
                     RAISE e_object_error;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      /* Bug 30779 - dlF - 15-IV-2014 - Problemas al emitir pólizas autorizadas previamente*/
      IF v_tipo_fefecto IN (3, 4) AND v_csituac = 4
      THEN
         /* fin Bug 30779 - dlF - 15-IV-2014*/
         vpasexec := 11;
         /*Emissió de la pólissa.*/
         /*TrapÃ s de la pólissa a les taules EST, per poder emetre la pólissa.*/
         pac_alctr126.traspaso_tablas_seguros (psseguro, vterror);

         IF vterror IS NOT NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, NULL, vterror);
            RAISE e_object_error;
         END IF;

         vpasexec := 12;

         SELECT e.sseguro
           INTO vvsseguro
           FROM estseguros e
          WHERE e.ssegpol = psseguro AND ROWNUM = 1;      /*//ACC per treure*/

         vpasexec := 13;

         FOR rie IN c_rie (psseguro, 'EST')
         LOOP
            vnumerr :=
               pac_md_produccion.f_tarifar_riesgo_tot ('EST',
                                                       vvsseguro,
                                                       rie.nriesgo,
                                                       pnmovimi,
                                                       TRUNC (f_sysdate),
                                                       mensajes
                                                      );

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END LOOP;

         pac_alctr126.borrar_tablas_est (vvsseguro);
      END IF;

      /*COMMIT; -- dra 27-10-2008: bug mantis 7519*/
      vpasexec := 14;
      /* BUG23911:DRA:19/10/2012:Inici*/
      vnumerr := pac_iax_produccion.f_set_isaltacolect (mensajes);

      -- INI IAXIS-5274 12/02/2020
      IF pac_iax_produccion.poliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        1000644,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_param_error;
      END IF;

      rie :=
         pac_iobj_prod.f_partpolriesgo (pac_iax_produccion.poliza.det_poliza,
                                        1,
                                        mensajes
                                       );

      IF rie IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes,
                                              1,
                                              1000646,
                                              'No se ha encontrado el riesgo'
                                             );
         RAISE e_object_error;
      END IF;

      pri := rie.f_get_primas (psseguro, pnmovimi, 'SEG');

      -- FIN IAXIS-5274 12/02/2020

      /* Bug 0016106 - RSC - 25/10/2010 - APR - Ajustes e implementación para el alta de colectivos*/
      /*      IF pac_iax_produccion.isaltacol = FALSE THEN*/
      IF pac_seguros.f_soycertifcero (vsproduc, vnpoliza, psseguro) = 1
      THEN
         vpasexec := 141;
         p_emitir_propuesta (vcempres,
                             vnpoliza,
                             vncertif,
                             vcramo,
                             vcmodali,
                             vctipseg,
                             vccolect,
                             vcactivi,
                             /* JLB - I - BUG 18423 COjo la moneda del producto*/
                             /*   1,*/
                             pac_monedas.f_moneda_producto (vsproduc),
                             /* JLB - f - BUG 18423 COjo la moneda del producto*/
                             vcidioma,
                             indice,
                             indice_e,
                             v_cmotret,
                             pmensaje,       /* BUG 27642 - FAL - 24/04/2014*/
                             psproces,
                             NULL,
                             1,
                             pri.itotdev              -- IAXIS-5274 12/02/2020
                            );
      /* dra 27-10-2008: bug mantis 7519*/
      /* Bug 0016106 - RSC - 25/10/2010 - APR - Ajustes e implementación para el alta de colectivos*/
      ELSE
         vpasexec := 142;
         pac_seguros.p_emitir_propuesta_col
                                    (vcempres,
                                     vnpoliza,
                                     vncertif,
                                     vcramo,
                                     vcmodali,
                                     vctipseg,
                                     vccolect,
                                     vcactivi,
                                     /* JLB - I - BUG 18423 COjo la moneda del producto*/
                                     /*       1,*/
                                     pac_monedas.f_moneda_producto (vsproduc),
                                     /* JLB - f - BUG 18423 COjo la moneda del producto,*/
                                     vcidioma,
                                     indice,
                                     indice_e,
                                     v_cmotret,
                                     psproces,
                                     NULL,
                                     1
                                    );
      END IF;

      /* BUG23911:DRA:19/10/2012:Fi*/
      vpasexec := 15;

      /* BUG 27642 - FAL - 24/04/2014*/
      IF pmensaje IS NOT NULL
      THEN
         /* and pmensaje = 9906016 then*/
         v_cmotret := 53;
      END IF;

      /* FI BUG 27642*/
      /* BUG9640:DRA:22/04/2009:Inici*/
      vnumerr :=
         pac_emision_mv.f_texto_emision (psseguro,
                                         indice,
                                         indice_e,
                                         v_cmotret,
                                         pac_md_common.f_get_cxtidioma,
                                         vtmsg
                                        );

      /* BUG 27642 - FAL - 24/04/2014*/
      IF pmensaje IS NOT NULL
      THEN
         /*and pmensaje = 9906016 then*/
         vtmsg := vtmsg || pmensaje;
      END IF;

      /* FI BUG 27642*/
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      /* BUG9640:DRA:22/04/2009:Fi*/
      vpasexec := 16;

      IF indice_e = 0 AND indice >= 1
      THEN
         vpasexec := 17;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 0, vtmsg);
      ELSE
         /* BUG9640:DRA:30-03-2009:Inici*/
         vpasexec := 18;
         ROLLBACK;
         vnumerr :=
            pac_emision_mv.f_retener_poliza ('SEG',
                                             psseguro,
                                             1,
                                             pnmovimi,
                                             NVL (v_cmotret, 5),
                                             1,
                                             f_sysdate
                                            );

         /* BUG 27642 - FAL - 24/04/2014*/
         IF pmensaje IS NOT NULL
         THEN
            UPDATE psucontrolseg
               SET observ = observ || pmensaje
             WHERE sseguro = psseguro
               AND ccontrol =
                      pac_parametros.f_parempresa_n (vcempres,
                                                     'CONROLPSU_RETENCIO'
                                                    )
               AND pac_parametros.f_parempresa_n (vcempres,
                                                  'CONROLPSU_RETENCIO'
                                                 ) IS NOT NULL;

            vnumerr :=
                  pac_motretencion.f_set_retencion (psseguro, 1, pnmovimi, 53);

            IF vnumerr <> 0
            THEN
               RAISE e_object_error;
            END IF;

            /*
            v_existe := 0;

            SELECT COUNT(1)
              INTO v_existe
              FROM motretencion
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = 1
               AND cmotret = 53;

            IF v_existe = 0 THEN
               BEGIN
                  SELECT NVL(MAX(nmotret), 0) + 1
                    INTO n_nmotret
                    FROM motretencion
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND nriesgo = 1;
               END;

               INSERT INTO motretencion
                           (sseguro, nriesgo, nmovimi, cmotret, cusuret,
                            freten, nmotret, cestgest)
                    VALUES (psseguro, 1, pnmovimi, 53, pac_md_common.f_get_cxtusuario,
                            f_sysdate, n_nmotret, NULL);
            END IF;
            */
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 0, vtmsg);
         ELSE
            /* FI BUG 27642*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 0, vtmsg);
         END IF;

         /* BUG9640:DRA:30-03-2009:Fi*/
         /* COMMIT;   -- dra 27-10-2008: bug mantis 7519*/
         RETURN 1;
      END IF;

      /* I - 31/10/2012 jlb - 23823*/
      /* Llamo a las listas restringidas*/
      /* Accion: anulaci??e p??a*/
      vnumerr :=
         pac_listarestringida.f_valida_listarestringida (psseguro,
                                                         NVL (pnmovimi, 1),
                                                         NULL,
                                                         4,
                                                         NULL,
                                                         NULL,
                                                         NULL
                                                        /* Bug 31411/175020 - 16/05/2014 - AMC*/
                                                        );

      IF vnumerr <> 0
      THEN
         RETURN vnumerr;
      END IF;

      vnumerr :=
         pac_listarestringida.f_valida_listarestringida (psseguro,
                                                         NVL (pnmovimi, 1),
                                                         NULL,
                                                         5,
                                                         NULL,
                                                         NULL,
                                                         NULL
                                                        /* Bug 31411/175020 - 16/05/2014 - AMC*/
                                                        );

      IF vnumerr <> 0
      THEN
         RETURN vnumerr;
      END IF;

      /* F - 31/10/2012- jlb - 23823*/
      /* COMMIT;  -- dra 27-10-2008: bug mantis 7519*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_emitirpropuesta;

   /*************************************************************************
      Editar la propuesta de póliza retenida
      param in  psseguro : código de póliza
      param out osseguro : código de la poliza a editar
      param in  pcestpol : Estado de la póliza en el momento de la edicion
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido errores
   *************************************************************************/
   FUNCTION f_editarpropuesta (
      psseguro   IN       NUMBER,
      osseguro   OUT      NUMBER,
      onmovimi   OUT      NUMBER,                 /* BUG14754:DRA:01/06/2010*/
      pcestpol   IN       VARCHAR2,               /* BUG11288:DRA:19/10/2009*/
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vterror     VARCHAR (2000);
      vnumerr     NUMBER (8);
      vcreteni    NUMBER;
      vttext      VARCHAR2 (1000);
      vnmovimi    NUMBER;
      vpasexec    NUMBER (8)      := 1;
      vparam      VARCHAR2 (100)  := 'psseguro= ' || psseguro;
      vobject     VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.F_EditarPropuesta';
      vparampsu   NUMBER;
      vsproduc    NUMBER;
      vpcestpol   VARCHAR (100);
   BEGIN
      SELECT MAX (nmovimi)
        INTO vnmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

      onmovimi := vnmovimi;                       /* BUG14754:DRA:01/06/2010*/
      vpasexec := 2;
      /*Comprovem l'estat en que es troba la proposta*/
      vnumerr := pac_gestion_retenidas.f_estado_propuesta (psseguro, vcreteni);
      vpasexec := 3;

      IF vnumerr <> 0
      THEN
         /*Error recuperant el tipus de retenció de la pólissa.*/
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'EDI_POL_PSU_RETENIDA'
                                            ),
              0
             ) = 1
      THEN
         vpcestpol := 'RET';
      ELSE
         vpcestpol := '***';
      END IF;

      /*Actuem segons l'estat de la proposta*/
      IF vcreteni = 2 AND NVL (pcestpol, vpcestpol) <> 'RET'
      THEN
         -- BUG11288:DRA:19/10/2009
         /*Proposta pendent d'autorització => No es pot emetre la proposta.*/
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 140598);
         RAISE e_object_error;
      ELSIF vcreteni IN (3, 4)
      THEN
         /*Proposta anulada o rebutjada => No es por emetre la proposta.*/
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151177);
         RAISE e_object_error;
      ELSIF vcreteni = 1 AND NVL (pcestpol, '***') <> 'RET'
      THEN
         --// ACC vigilar que el nmovimi
         /*Proposta retinguda => Abans d'emetre-la comprovem que no tingui errors en l'emissió*/
         vpasexec := 5;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         vparampsu := pac_parametros.f_parproducto_n (vsproduc, 'PSU');

         IF NVL (vparampsu, 0) = 0
         THEN
            vnumerr :=
               pac_motretencion.f_risc_retingut (psseguro,
                                                 NVL (vnmovimi, 1),
                                                 1,
                                                 5
                                                );

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151237);
               RAISE e_object_error;
            END IF;

            vpasexec := 6;
            /*Com que es tractava d'una retenció voluntaria, l'acceptem.*/
            vttext := f_axis_literales (151726, pac_md_common.f_get_cxtidioma);
            vnumerr :=
               pac_motretencion.f_desretener (psseguro,
                                              NVL (vnmovimi, 1),
                                              vttext
                                             );
            /*// ACC vigilar que el nmovimi*/
            vpasexec := 7;

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      vpasexec := 8;
      /*TrapÃ s de la pólissa a les taules EST, per poder emetre la pólissa.*/
      /* BUG9329:DRA:09/06/2009:Inici*/
      /* pac_alctr126.traspaso_tablas_seguros(psseguro, vterror);*/
      vnumerr :=
         pk_nueva_produccion.f_inicializar_modificacion (psseguro,
                                                         osseguro,
                                                         vnmovimi,
                                                         'ALTA_POLIZA',
                                                         NULL,
                                                         NULL
                                                        );

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      /* BUG9329:DRA:09/06/2009:Fi*/
      vpasexec := 9;
      /* COMMIT;  -- BUG11288:DRA:20/10/2009: Lo pasamos a la capa IAX*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         /* ROLLBACK;  -- BUG11288:DRA:20/10/2009: Lo pasamos a la capa IAX*/
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         /* ROLLBACK;  -- BUG11288:DRA:20/10/2009: Lo pasamos a la capa IAX*/
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         /* ROLLBACK;  -- BUG11288:DRA:20/10/2009: Lo pasamos a la capa IAX*/
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_editarpropuesta;

/************************************************************************
                             FI RETENCIÓN PÓLIZAS
************************************************************************/
/*JRH 03/2008*/
/*************************************************************************
  Acciones post tarificación
  (para ello se debe guardar toda la información a la base de datos)
  param in nriesgo   : número de riesgo
  param out mensajes : mensajes de error
  return             : 0 todo correcto
                       1 ha habido un error
*************************************************************************/
   FUNCTION f_accionposttarif (
      tablas     IN       VARCHAR2,
      vsolicit   IN       NUMBER,
      nriesgo    IN       NUMBER,
      vnmovimi   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (1)     := NULL;
      vobject      VARCHAR2 (200)   := 'PAC_MD_PRODUCCION.F_AccionPostTarif';
      det_poliza   ob_iax_detpoliza;
      prima_per    NUMBER;
      durac        NUMBER;
      ocoderror    NUMBER;
      vorigen      NUMBER;
   BEGIN
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        32332,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_object_error;
      END IF;

      IF     NVL (f_parproductos_v (det_poliza.sproduc, 'ES_PRODUCTO_RENTAS'),
                  0
                 ) = 1
         AND vnmovimi = 1
      THEN
         /*JRH IMP*/
         prima_per :=
                pac_calc_comu.ff_capital_gar_tipo (tablas, vsolicit, 1, 3, 1);
         durac := pac_calc_comu.ff_get_duracion (tablas, vsolicit);
         pac_ref_contrata_rentas.f_actualizar_segurosren
                                              (det_poliza.sproduc,
                                               det_poliza.gestion.fefecto,
                                               durac,
                                               /*Se rige por periodo o rev*/
                                               det_poliza.gestion.fvencim,
                                               det_poliza.gestion.cforpag,
                                               prima_per,
                                               det_poliza.gestion.pcapfall,
                                               NULL,
                                               NULL,
                                               NULL,
                                               det_poliza.gestion.pdoscab,
                                               det_poliza.gestion.cforpagren,
                                               vsolicit,
                                               ocoderror,
                                               tablas,
                                               /* Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratación e interás*/
                                               det_poliza.gestion.fppren
                                              );

         /* Fi Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303*/
         IF ocoderror <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180584);
            RETURN 1;
         END IF;
      END IF;

      /* BUG 16217 - 09/2010 - JRH  -  Cuadro de provisiones*/
      IF     NVL (f_parproductos_v (det_poliza.sproduc, 'ES_PRODUCTO_RENTAS'),
                  0
                 ) = 1
         AND NVL (f_parproductos_v (det_poliza.sproduc, 'CUADROEVOLUPROV'), 0) =
                                                                             1
      THEN
         IF tablas = 'EST'
         THEN
            vorigen := 1;
         ELSE
            vorigen := 2;
         END IF;

         ocoderror :=
                 pk_rentas.f_gen_evoluprovmatseg (vsolicit, vnmovimi, vorigen);

         IF ocoderror <> 0
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'f_tarifar_riesgo_tot',
                         191,
                            'vsolicit = '
                         || vsolicit
                         || ' vnmovimi = '
                         || vnmovimi
                         || ' vorigen = '
                         || vorigen,
                         ocoderror
                        );
         END IF;
      END IF;

      /* Fi BUG 16217 - 09/2010 - JRH*/
      RETURN (0);
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_accionposttarif;

   /*************************************************************************
     Cálculo fecha renovación según producto y fecha efecto/fecha actual
     param in psproduc  : número de riesgo
     param in pfecha    : fecha efecto (por defecto fecha actual)
     param in out dtPoliza  : objeto detalle póliza
     param    out mensajes : mensajes de error
     return             : 0 = todo correcto
                          1 = ha habido un error
   *************************************************************************/
   FUNCTION f_calcula_nrenova (
      psproduc   IN       NUMBER,
      pfecha     IN       DATE DEFAULT f_sysdate,
      dtpoliza   IN OUT   ob_iax_detpoliza,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
         :=    'psproduc='
            || psproduc
            || ' pfecha='
            || TO_CHAR (pfecha, 'dd/mm/yyyy');
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_CALCULA_NRENOVA';
      vnrenova   NUMBER;
      vnumerr    NUMBER;
   BEGIN
      vpasexec := 2;

      IF psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      /* BUG9523:18/03/2009:DRA*/
      vnumerr := pac_calc_comu.f_calcula_nrenova (psproduc, pfecha, vnrenova);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      dtpoliza.nrenova := vnrenova;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_calcula_nrenova;

   /*************************************************************************
      Nos indica si hay garantÃ­a con revalorizción diferente que la de la póliza
      param in psseguro  : Póliza
      param in pnriesgo    : número de riesgo
      param out mensajes : mensajes de error
      return             : 0 = Si las garantÃ­as tienen igual revalorización
                           1 = Si alguna garantÃ­a tiene diferente revalorización
   *************************************************************************/
   FUNCTION f_gar_reval_dif (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vcrevali   NUMBER;
      virevali   NUMBER;
      vprevali   NUMBER;

      CURSOR tab_est
      IS
         SELECT g.crevali, g.irevali, g.prevali
           FROM estgaranseg g, estseguros s, garanpro p
          WHERE g.sseguro = psseguro
            AND g.nmovimi = pac_iax_produccion.vnmovimi
            AND g.nriesgo = pnriesgo
            AND NVL (g.crevali, 0) <> 0
            AND s.sseguro = g.sseguro
            AND p.ctipgar NOT IN (8, 9)
            AND p.cgarant = g.cgarant
            AND p.sproduc = s.sproduc
            AND p.cactivi = s.cactivi
         MINUS
         SELECT crevali, irevali, prevali
           FROM estseguros
          WHERE sseguro = psseguro;

      CURSOR tab_seg
      IS
         SELECT g.crevali, g.irevali, g.prevali
           FROM garanseg g, seguros s, garanpro p
          WHERE g.sseguro = psseguro
            AND g.nmovimi = pac_iax_produccion.vnmovimi
            AND g.nriesgo = pnriesgo
            AND NVL (g.crevali, 0) <> 0
            AND s.sseguro = g.sseguro
            AND p.ctipgar NOT IN (8, 9)
            AND p.cgarant = g.cgarant
            AND p.sproduc = s.sproduc
            AND p.cactivi = s.cactivi
         MINUS
         SELECT crevali, irevali, prevali
           FROM seguros
          WHERE sseguro = psseguro;

      vpasexec   NUMBER (8)     := 1;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_gar_reval_dif';
      vparam     VARCHAR2 (100)
                        := 'psseguro=' || psseguro || ' pnriesgo=' || pnriesgo;
   BEGIN
      IF psseguro IS NULL OR pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*

      IF poliza.det_poliza IS NULL THEN
          PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,1,-456,'No se ha inicializado correctamente');
          RAISE e_param_error;
      END IF;

      vpasexec:=2;
      rie:= PAC_IOBJ_PROD.F_Partpolriesgo(poliza.det_poliza,nriesgo,mensajes);
      IF rie is null THEN
          PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,1,49773,'No se ha encontrado el riesgo');
          vpasexec:=3;
          RAISE e_object_error;
      END IF;

      vpasexec:=4;
      gars:= PAC_IOBJ_PROD.F_Partriesgarantias(rie,mensajes);
      IF gars is null THEN
          PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,1,87633,'El riesgo no tiene garantias asociadas');
          vpasexec:=5;
          RAISE e_object_error;
      ELSE
          IF gars.count=0 THEN
              PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje(mensajes,1,87733,'El riesgo no tiene garantias asociadas');
              vpasexec:=6;
              RAISE e_object_error;
          END IF;
      END IF;


      vpasexec:=7;
      FOR vgar IN gars.first..gars.last LOOP
          vpasexec:=8;
          IF gars.exists(vgar) THEN
            IF gars(vgar).crevali<>0 and gars(vgar).ctipgar not in (8,9) THEN --JRH 06/2008 En estos casos no podemos cambiar la revalorización
              vpasexec:=9;
              gars(vgar).crevali := crevali;
              gars(vgar).prevali := prevali;
              gars(vgar).irevali := irevali;
            END IF;
          END IF;
      END LOOP;

      vpasexec:=10;
      poliza.det_poliza.crevali:=crevali;
      poliza.det_poliza.prevali:=prevali;
      poliza.det_poliza.irevali:=irevali;








      */
      IF pac_iax_produccion.vpmode = 'EST'
      THEN
         OPEN tab_est;

         FETCH tab_est
          INTO vcrevali, virevali, vprevali;

         IF tab_est%NOTFOUND
         THEN
            CLOSE tab_est;

            RETURN 0;
         END IF;
      ELSE
         OPEN tab_seg;

         FETCH tab_seg
          INTO vcrevali, virevali, vprevali;

         IF tab_seg%NOTFOUND
         THEN
            CLOSE tab_seg;

            RETURN 0;
         END IF;
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END;

   /***********************************************************************
      Establece las preguntas asignadas a las garantias del producto para insertalas en el riesgo
      param in out pregs : objeto preguntas
      param in pnmovimi : número de movimiento
      param in out mensajes : mensajes error
      return             : O todo correcto
                           1 ha habido un error
   ***********************************************************************/
   FUNCTION p_set_garanpregunprod (
      pregs      IN OUT   t_iax_preguntas,
      pcgarant   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      pregp        t_iaxpar_preguntas;
      det_poliza   ob_iax_detpoliza;
      nerr         NUMBER             := -1;
      vpasexec     NUMBER (8)         := 1;
      vparam       VARCHAR2 (300)
                      := 'pcgarant=' || pcgarant || ', pnmovimi=' || pnmovimi;
      vobject      VARCHAR2 (200)
                                 := 'PAC_MD_PRODUCCION.P_Set_GaranPregunProd';

      FUNCTION existpreg (cpregun IN NUMBER)
         RETURN NUMBER
      IS
      BEGIN
         IF pregs IS NULL
         THEN
            RETURN -1;
         END IF;

         IF pregs.COUNT = 0
         THEN
            RETURN -1;
         END IF;

         FOR vpreg IN pregs.FIRST .. pregs.LAST
         LOOP
            IF pregs.EXISTS (vpreg)
            THEN
               IF pregs (vpreg).cpregun = cpregun
               THEN
                  RETURN vpreg;
               END IF;
            END IF;
         END LOOP;

         RETURN -1;
      END existpreg;
   BEGIN
      IF pregs IS NULL
      THEN
         pregs := t_iax_preguntas ();
      END IF;

      vpasexec := 1;
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        32332,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      pregp := pac_iaxpar_productos.f_get_preggarant (pcgarant, mensajes);

      IF pregp IS NOT NULL
      THEN
         vpasexec := 11;

         IF pregp.COUNT > 0
         THEN
            vpasexec := 12;

            FOR vpreg IN pregp.FIRST .. pregp.LAST
            LOOP
               vpasexec := 13;

               IF pregp.EXISTS (vpreg)
               THEN
                  vpasexec := 14;

                  IF existpreg (pregp (vpreg).cpregun) = -1
                  THEN
                     nerr := 0;
                     /* te canvis*/
                     vpasexec := 15;
                     pregs.EXTEND;
                     pregs (pregs.LAST) := ob_iax_preguntas ();
                     pregs (pregs.LAST).cpregun := pregp (vpreg).cpregun;
                     pregs (pregs.LAST).nmovimi := pnmovimi;
                     pregs (pregs.LAST).nmovima := pnmovimi;
                     pregs (pregs.LAST).finiefe := det_poliza.gestion.fefecto;
                     pregs (pregs.LAST).crespue := NULL;
                     vpasexec := 16;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 2;
            RETURN 1;
         END IF;
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END p_set_garanpregunprod;

   /***********************************************************************
   Borra de la tabla est_per_personas y de esttomadores las personas que toca al
   cancelar una simulación.
   param in pnmovimi : psseguro de la simulación.
   param in out mensajes : mensajes error
   return             : O todo correcto
   1 ha habido un error
   ***********************************************************************/
   FUNCTION f_get_personsimul (
      psseguro   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr       NUMBER         := -1;
      cont_tom   NUMBER         := 0;
      cont_ase   NUMBER         := 0;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (300) := 'psseguro=' || psseguro;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Get_PersonSimul';

      CURSOR pers
      IS
         SELECT sperson
           FROM estper_personas
          WHERE sseguro = psseguro;
   BEGIN
      nerr := 0;

      FOR per IN pers
      LOOP
         SELECT COUNT ('1')
           INTO cont_ase
           FROM estassegurats
          WHERE sperson = per.sperson AND sseguro = psseguro
                AND ffecfin IS NULL;              /* BUG11183:DRA:23/09/2009*/

         IF cont_ase = 0
         THEN
            pac_persona.borrar_tablas_estper (per.sperson);
         END IF;
      END LOOP;

      DELETE FROM esttomadores
            WHERE sseguro = psseguro;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 2;
            RETURN 1;
         END IF;
      END IF;

      RETURN (nerr);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_personsimul;

   /***********************************************************************
   Borra de las tablas est los datos que tocan al cancelar una simulación.
   param in pnmovimi : psseguro de la simulación.
   param in out mensajes : mensajes error
   return             : O todo correcto
                      1 ha habido un error
   ***********************************************************************/
   FUNCTION f_borra_datos_prod_simul (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr       NUMBER         := -1;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (300)
                       := 'psseguro=' || psseguro || ', pnmovimi' || pnmovimi;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_PRODUCCION.F_BORRA_ESTGARANSEG_SIMUL';
   BEGIN
      nerr := 0;

      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      DELETE FROM estgaranseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM estclaususeg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM estclausuesp
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM estclaubenseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      RETURN (nerr);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_borra_datos_prod_simul;

   /***********************************************************************
      Recupera la fecha de revisión de la póliza
      param in psproduc  : código del producto
               pnduraci  : duración de la póliza
               pndurper  : duración del perÃ­odo
               pfefecto  : fecha de efecto
      param out  pfrevisio : fecha de revisión de la póliza
                 mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_frevisio (
      psproduc    IN       NUMBER,
      pnduraci    IN       NUMBER,
      pndurper    IN       NUMBER,
      pfefecto    IN       DATE,
      pfrevisio   OUT      DATE,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'psproduc: '
            || psproduc
            || ' - '
            || 'pnduraci: '
            || pnduraci
            || ' - '
            || 'pndurper: '
            || pndurper
            || ' - '
            || 'pfefecto: '
            || pfefecto;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Get_FRevisio';
      num_err    NUMBER;
   BEGIN
      num_err :=
         pac_calc_comu.f_calcula_frevisio (psproduc,
                                           pnduraci,
                                           pndurper,
                                           pfefecto,
                                           pfrevisio
                                          );

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN 1;
   END f_get_frevisio;

   /***********************************************************************
      Recupera el agente con el que está grabada la persona en las tablas est
      param in psperson  : código de la persona
      param out pcagente : codigo agente
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_busca_agente_poliza (
      psperson   IN       NUMBER,
      pcagente   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500) := 'psperson: ' || psperson;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Busca_Agente_Poliza';
      num_err    NUMBER;
   BEGIN
      RETURN pac_propio_int.f_busca_agente_poliza (psperson, pcagente);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN 1;
   END f_busca_agente_poliza;

   /***********************************************************************
      Devuelve el valor de la revalorización de una póliza.
      param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales, 'SOL' - solicitudes)
      param in psseguro  : Número interno de seguro
      param out prevali  : Porcentaje o valor de revalorización
      param out pcrevali : Tipo de revalorización
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_reval_poliza (
      ptablas    IN       VARCHAR2 DEFAULT 'SEG',
      psseguro   IN       NUMBER,
      prevali    OUT      NUMBER,
      pcrevali   OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)     := 1;
      vparam       VARCHAR2 (500)
                      := 'PTABLAS: ' || ptablas || ', PSSEGURO: ' || psseguro;
      vobject      VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Get_Reval_Poliza';
      v_nrevali    NUMBER;
      v_crevali    NUMBER;
      v_irevali    NUMBER;
      v_prevali    NUMBER;
      num_err      NUMBER;
      v_pcrevali   NUMBER;
      v_pirevali   NUMBER;
      v_count      NUMBER;
      v_nriesgo    NUMBER;
      vplan        NUMBER;

      CURSOR c_riesgo
      IS
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = psseguro;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      prevali :=
         pac_calc_comu.f_get_reval_poliza (NVL (ptablas, 'SEG'),
                                           psseguro,
                                           pcrevali
                                          );
      vpasexec := 3;

      IF prevali IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 111399);
         RAISE e_object_error;
      END IF;

      IF     pac_mdpar_productos.f_get_parproducto
                                 ('ADMITE_CERTIFICADOS',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ) = 1
         AND NOT pac_iax_produccion.isaltacol
      THEN
         num_err :=
            pac_productos.f_get_herencia_col
                               (pac_iax_produccion.poliza.det_poliza.sproduc,
                                11,
                                v_pcrevali
                               );
         num_err :=
            pac_productos.f_get_herencia_col
                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                 12,
                                 v_pirevali
                                );

         SELECT COUNT (1)
           INTO v_count
           FROM seguros
          WHERE ncertif = 0
            AND npoliza = pac_iax_produccion.poliza.det_poliza.npoliza;

         IF     NVL (v_pcrevali, 0) = 1
            AND NVL (v_pirevali, 0) = 1
            AND num_err = 0
            AND v_count > 0
         THEN
            /*BUG 27539/149706 - INICIO - DCT - 23/07/2013*/
            IF     pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
               AND pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
            THEN
               FOR i IN
                  pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
               LOOP
                  IF pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun =
                                                                         4089
                  THEN
                     vplan :=
                        pac_iax_produccion.poliza.det_poliza.preguntas (i).crespue;
                  END IF;
               END LOOP;
            END IF;

            /* SCO bug 27417/0163190 - INICIO*/
            BEGIN
               SELECT g.crevali, NVL (g.prevali, 0), NVL (g.irevali, 0)
                 INTO v_crevali, v_prevali, v_irevali
                 FROM garanseg g, seguros s, garanpro gg
                WHERE g.sseguro = s.sseguro
                  AND s.sproduc = gg.sproduc
                  AND g.cgarant = gg.cgarant
                  AND g.nriesgo = vplan
                  AND g.ffinefe IS NULL
                  AND gg.sproduc = s.sproduc
                  AND gg.cgarant = g.cgarant
                  AND gg.cbasica = 1
                  AND ROWNUM = 1
                  AND s.npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
                  AND s.ncertif = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT g.crevali, NVL (g.prevali, 0), NVL (g.irevali, 0)
                       INTO v_crevali, v_prevali, v_irevali
                       FROM garanseg g, seguros s, garanpro gg
                      WHERE g.sseguro = s.sseguro
                        AND g.nriesgo = vplan
                        AND g.ffinefe IS NULL
                        AND gg.sproduc = s.sproduc
                        AND gg.cgarant = g.cgarant
                        AND ROWNUM = 1
                        AND s.npoliza =
                                  pac_iax_produccion.poliza.det_poliza.npoliza
                        AND s.ncertif = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_crevali := 0;
                        v_prevali := 0;
                        v_irevali := 0;
                        p_tab_error
                           (f_sysdate,
                            f_user,
                            'pac_md_produccion.f_get_reval_poliza',
                            vpasexec,
                               'No se ha encontrado revalorización de la garantÃ­a. - vplan='
                            || vplan
                            || ' - npoliza='
                            || pac_iax_produccion.poliza.det_poliza.npoliza,
                            SQLERRM
                           );
                  END;
            END;

            /* SCO bug 27417/0163190 - FIN*/
            /*BUG 27539/149706 - FIN - DCT - 23/07/2013*/
            /*Actualizo las garantias*/
            FOR i IN c_riesgo
            LOOP
               num_err :=
                  pac_iax_produccion.f_set_revalriesgo (i.nriesgo,
                                                        v_crevali,
                                                        v_prevali,
                                                        v_irevali,
                                                        mensajes
                                                       );
            END LOOP;

            IF v_crevali = 1
            THEN
               /* Lineal*/
               v_nrevali := v_irevali;
            ELSIF v_crevali = 2
            THEN
               /* Geomátrica*/
               v_nrevali := v_prevali;
            ELSE
               v_nrevali := v_prevali;
            /*JRH Tarea 6966*/
            END IF;

            pcrevali := v_crevali;
            prevali := v_nrevali;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN -1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN -1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN -1;
   END f_get_reval_poliza;

   /*ACC 13122008*/
   /*************************************************************************
   Inicializa la póliza con la parametrización del producto
   en cas de estar en mode consulta/suplement
   param in out dtPoliza : objeto detalle poliza
   param in out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE inicializaobjetosproduct (
      dtpoliza   IN OUT   ob_iax_detpoliza,
      mensajes   IN OUT   t_iax_mensajes
   )
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_PRODUCCION.InicializaObjetosProduct';
   BEGIN
      SELECT p.csubpro, p.cpagdef
        INTO dtpoliza.csubpro, dtpoliza.cpagdef
        FROM productos p
       WHERE sproduc = dtpoliza.sproduc;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
   END inicializaobjetosproduct;

/*ACC 13122008*/
/*-------------------------------------------------------------------------*/
/* Mantis 7919.#6.i.12/2008*/
/*-------------------------------------------------------------------------*/
   FUNCTION f_set_calc_ndurcob (
      psproduc   IN       productos.sproduc%TYPE,
      pgest      IN OUT   ob_iax_gestion,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      w_err        PLS_INTEGER;
      w_pas_exec   PLS_INTEGER    := 1;
      w_param      VARCHAR2 (500) := 'parametres: sproduc =' || psproduc;
      w_object     VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Set_Calc_NdurCob';
   /**/
   BEGIN
      w_err :=
         pac_calc_comu.f_calcula_ndurcob (psproduc /* entrada*/,
                                          pgest.duracion /* entrada*/,
                                          pgest.ndurcob   /* entrada/sortida*/
                                         );

      IF w_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, w_err);
         RAISE e_object_error;
      /**/
      END IF;

      RETURN (0);
   /**/
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000005,
                                            w_pas_exec,
                                            w_param
                                           );
         RETURN (1);
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000006,
                                            w_pas_exec,
                                            w_param
                                           );
         RETURN (1);
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000001,
                                            w_pas_exec,
                                            w_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (1);
   END f_set_calc_ndurcob;

/*-------------------------------------------------------------------------*/
/* Mantis 7919.#6.f.12/2008*/
/*-------------------------------------------------------------------------*/
/***********************************************************************
   Devuelve un objeto con los datos de gestión de una póliza.
   param in psseguro  : Número interno de seguro
   param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales, 'SOL' - solicitudes)
   param out mensajes : mensajes de error
   return             : ob_iax_poliza
***********************************************************************/
   FUNCTION f_get_datos_cobro (
      psseguro   IN       NUMBER,
      ptablas    IN       VARCHAR2 DEFAULT 'SEG',
      mensajes   OUT      t_iax_mensajes
   )
      RETURN ob_iax_gestion
   IS
      vpasexec    NUMBER (8)     := 1;
      vparam      VARCHAR2 (500)
                      := 'PTABLAS: ' || ptablas || ', PSSEGURO: ' || psseguro;
      vobject     VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_get_datos_cobro';
      num_err     NUMBER         := 0;
      o_gestion   ob_iax_gestion := ob_iax_gestion ();
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF ptablas = 'EST'
      THEN
         SELECT seg.cbancar, seg.cforpag, seg.ctipcob,
                seg.fefecto, seg.ccobban, seg.ctipban
           INTO o_gestion.cbancar, o_gestion.cforpag, o_gestion.ctipcob,
                o_gestion.fefecto, o_gestion.ccobban, o_gestion.ctipban
           FROM estseguros seg
          WHERE seg.sseguro = psseguro;
      ELSE
         SELECT seg.cbancar, seg.cforpag, seg.ctipcob,
                seg.fefecto, seg.ccobban, seg.ctipban
           INTO o_gestion.cbancar, o_gestion.cforpag, o_gestion.ctipcob,
                o_gestion.fefecto, o_gestion.ccobban, o_gestion.ctipban
           FROM seguros seg
          WHERE seg.sseguro = psseguro;
      END IF;

      vpasexec := 3;
      RETURN o_gestion;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_datos_cobro;

   /*************************************************************************
    Establece las preguntas asignadas al producto para insertalas en la poliza
    param in pnmovimi  :    código de movimiento
    param in pfefecto  :    fecha de efecto
    param in out ppoliza :    Objeto póliza E/S
    return             :    NUMBER
   *************************************************************************/
   /* Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomáticas*/
   FUNCTION f_grabar_semiautomatpol (
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      ppoliza    IN OUT   ob_iax_poliza,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vtprefor     VARCHAR2 (100);
      v_resp       NUMBER;
      preg         t_iax_preguntas;
      num_err      NUMBER;
      vaux         NUMBER;
      w_err        PLS_INTEGER;
      w_pas_exec   PLS_INTEGER     := 1;
      w_param      VARCHAR2 (500)
         := 'parametres: pnmovimi =' || pnmovimi || ' pfefecto = '
            || pfefecto;
      w_object     VARCHAR2 (200)
                              := 'PAC_MD_PRODUCCION.f_grabar_semiautomaticas';
      v_ctippre    NUMBER;
   BEGIN
      IF ppoliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        -456,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_param_error;
      END IF;

      w_pas_exec := 2;
      preg := pac_iobj_prod.f_partpolpreguntas (ppoliza.det_poliza, mensajes);
      w_pas_exec := 3;

      /* Bug 9858 - RSC - 28/04/2009 - se controla que existan preguntas de garantÃ­a*/
      IF preg IS NOT NULL
      THEN
         IF preg.COUNT > 0
         THEN
            /* preg = T_IAX_PREGUNTAS (Colección de OB_IAX_PREGUNTAS)*/
            /* que no contiene la información de si la pregunta es semiautomatica o no.*/
            FOR i IN preg.FIRST .. preg.LAST
            LOOP
               w_pas_exec := 4;

               IF pac_mdpar_productos.f_es_semiautomatica
                                                 (ppoliza.det_poliza.sproduc,
                                                  preg (i).cpregun,
                                                  'P',
                                                  mensajes
                                                 ) = 1
               THEN
                  w_pas_exec := 5;
                  vtprefor :=
                     pac_mdpar_productos.f_get_tpreforsemi
                                                 (ppoliza.det_poliza.sproduc,
                                                  preg (i).cpregun,
                                                  'P',
                                                  mensajes
                                                 );
                  w_pas_exec := 6;

                  IF pac_iax_produccion.issuplem
                  THEN
                     NULL;            /* En modeo suplemento anda que hacer*/
                     RETURN (0);
                  ELSE
                     w_pas_exec := 7;

                     IF NVL (f_parproductos_v (ppoliza.det_poliza.sproduc,
                                               'ADMITE_CERTIFICADOS'
                                              ),
                             0
                            ) = 1
                     THEN
                        num_err :=
                           pac_albsgt.f_tprefor (vtprefor,
                                                 'EST',
                                                 ppoliza.det_poliza.sseguro,
                                                 1,
                                                 pfefecto,
                                                 pnmovimi,
                                                 0,
                                                 v_resp,
                                                 1,
                                                 1,
                                                 0,
                                                 ppoliza.det_poliza.npoliza
                                                );
                     /* Bug 22839 - RSC - 18/07/2012*/
                     ELSE
                        num_err :=
                           pac_albsgt.f_tprefor (vtprefor,
                                                 'EST',
                                                 ppoliza.det_poliza.sseguro,
                                                 1,
                                                 pfefecto,
                                                 pnmovimi,
                                                 0,
                                                 v_resp,
                                                 1
                                                );
                     END IF;
                  END IF;

                  w_pas_exec := 8;

                  /* Bug 23863/124692 - AMC - 11/01/2013*/
                  IF preg (i).crespue IS NULL AND preg (i).trespue IS NULL
                  /*Bug 31686/180437 - 24/07/2014 - AMC*/
                  THEN
                     preg (i).crespue := v_resp;

                     /*Inici BUG 29315 - RCL - 06/02/2014*/
                     BEGIN
                        SELECT ctippre
                          INTO v_ctippre
                          FROM codipregun
                         WHERE cpregun = preg (i).cpregun;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_ctippre := 0;
                     END;

                     IF v_ctippre = 4
                     THEN
                        /*PREGUNTA DE TIPUS DATA*/
                        preg (i).trespue := TO_CHAR (v_resp, '09999999');
                     ELSE
                        preg (i).trespue := TO_CHAR (v_resp);
                     END IF;
                  /*Fi BUG 29315 - RCL - 06/02/2014*/
                  END IF;
               /* Fi Bug 23863/124692 - AMC - 11/01/2013*/
               END IF;
            END LOOP;
         END IF;
      END IF;

      /* Bug 9858 - RSC - 28/04/2009 - Fin*/
      w_pas_exec := 9;
      /* Grabamos de nuevo las preguntas en el objeto póliza*/
      ppoliza.det_poliza.preguntas := preg;
      RETURN (0);
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000001,
                                            w_pas_exec,
                                            w_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (1);
   END f_grabar_semiautomatpol;

   /*************************************************************************
    Establece las preguntas asignadas al producto para insertalas en la poliza
    param in pnmovimi  :    código de movimiento
    param in pfefecto  :    fecha de efecto
    param in out ppoliza :    Objeto póliza E/S
    param in out preg :    Preguntas de la póliza E/S
    param in out mensajes : mensajes de error
    param in pnriesgo  :    Identificador de riesgo tratado
    param in pcgarant  :    Identificador de garantÃ­a tratada
    return             :    NUMBER
   *************************************************************************/
   /* Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomáticas*/
   FUNCTION f_grabar_semiautomatriesgo (
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      ppoliza    IN OUT   ob_iax_poliza,
      preg       IN OUT   t_iax_preguntas,
      mensajes   OUT      t_iax_mensajes,
      pnriesgo   IN       NUMBER,
      pcgarant   IN       NUMBER
   )
      RETURN NUMBER
   IS
      vtprefor         VARCHAR2 (100);
      v_resp           NUMBER;
      /*preg        T_IAX_PREGUNTAS;*/
      num_err          NUMBER;
      vaux             NUMBER;
      w_err            PLS_INTEGER;
      w_pas_exec       PLS_INTEGER    := 1;
      w_param          VARCHAR2 (500)
         := 'parametres: pnmovimi =' || pnmovimi || ' pfefecto = '
            || pfefecto;
      w_object         VARCHAR2 (200)
                              := 'PAC_MD_PRODUCCION.f_grabar_semiautomaticas';
      vdisco           VARCHAR2 (1);
      /* BUG12215:DRA:18/01/2010:Inici*/
      v_cont_est       NUMBER;
      v_cont_rea       NUMBER;
      /* BUG12215:DRA:18/01/2010:Fi*/
      /* Bug 22839 - RSC - 20/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
      v_cont_est_gar   NUMBER;
      v_cont_gar       NUMBER;
      /* Fin bug 22839*/
      vcpretip         NUMBER;
      vesccero         NUMBER;
      v_ctippre        NUMBER;
      --bartolo
      cant_preg        NUMBER         := 0;
   --bartolo
   BEGIN
      IF ppoliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        -456,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_param_error;
      END IF;

      /*w_pas_exec := 2;*/
      /*preg := pac_iobj_prod.f_partpolpreguntas(ppoliza.det_poliza, mensajes);*/
      SELECT DECODE (pcgarant, NULL, 'R', 'G')
        INTO vdisco
        FROM DUAL;

      w_pas_exec := 3;

      /* Bug 9858 - RSC - 28/04/2009 - se controla que existan preguntas de garantÃ­a*/
      IF preg IS NOT NULL
      THEN
         IF preg.COUNT > 0
         THEN
            /* preg = T_IAX_PREGUNTAS (Colección de OB_IAX_PREGUNTAS)*/
            /* que no contiene la información de si la pregunta es semiautomatica o no.*/
            FOR i IN preg.FIRST .. preg.LAST
            LOOP
               w_pas_exec := 4;

               IF pac_mdpar_productos.f_es_semiautomatica
                                                 (ppoliza.det_poliza.sproduc,
                                                  preg (i).cpregun,
                                                  vdisco,
                                                  mensajes,
                                                  pcgarant
                                                 ) = 1
               THEN
                  w_pas_exec := 5;
                  vtprefor :=
                     pac_mdpar_productos.f_get_tpreforsemi
                                                 (ppoliza.det_poliza.sproduc,
                                                  preg (i).cpregun,
                                                  vdisco,
                                                  mensajes,
                                                  pcgarant
                                                 );
                  w_pas_exec := 6;

                  IF pac_iax_produccion.issuplem
                  THEN
                     w_pas_exec := 71;

                     /* Bug 11735 - RSC - 19/01/2010 - 0011735: APR - suplemento de modificación de capital /prima*/
                     IF pcgarant IS NOT NULL
                     THEN
                        IF pac_parametros.f_parproducto_n
                                                 (ppoliza.det_poliza.sproduc,
                                                  'DETALLE_GARANT'
                                                 ) IN (1, 2)
                        THEN
                           IF pac_iax_produccion.isaltagar
                           THEN
                              /*IF f_valida_alta_garantia(ppoliza, mensajes) = 1 THEN*/
                              w_pas_exec := 72;
                              num_err :=
                                 pac_albsgt.f_tprefor
                                                 (vtprefor,
                                                  'EST',
                                                  ppoliza.det_poliza.sseguro,
                                                  pnriesgo,
                                                  pfefecto,
                                                  pnmovimi,
                                                  pcgarant,
                                                  v_resp,
                                                  1
                                                 );
                           END IF;
                        END IF;
                     END IF;

                     /* Fin bug 11735*/
                     /* BUG12215:DRA:01/12/2009:inici*/
                     SELECT COUNT (1)
                       INTO v_cont_est
                       FROM estriesgos
                      WHERE sseguro = ppoliza.det_poliza.sseguro
                        AND fanulac IS NULL;

                     SELECT COUNT (1)
                       INTO v_cont_rea
                       FROM riesgos
                      WHERE sseguro = ppoliza.det_poliza.ssegpol
                        AND fanulac IS NULL;

                     /* Bug 22839 - RSC - 20/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
                     SELECT COUNT (*)
                       INTO v_cont_est_gar
                       FROM estgaranseg
                      WHERE sseguro = ppoliza.det_poliza.sseguro
                        AND nriesgo = pnriesgo
                        AND cgarant = pcgarant
                        AND cobliga = 1;

                     SELECT COUNT (*)
                       INTO v_cont_gar
                       FROM garanseg
                      WHERE sseguro = ppoliza.det_poliza.ssegpol
                        AND nriesgo = pnriesgo
                        AND cgarant = pcgarant
                        AND ffinefe IS NULL;

                     /* Fin bug 22839*/
                     vcpretip :=
                        pac_mdpar_productos.f_get_cpretippreg
                                                  (ppoliza.det_poliza.sproduc,
                                                   preg (i).cpregun,
                                                   vdisco,
                                                   mensajes,
                                                   pcgarant
                                                  );
                     vesccero :=
                        pac_mdpar_productos.f_get_escceropreg
                                                  (ppoliza.det_poliza.sproduc,
                                                   preg (i).cpregun,
                                                   vdisco,
                                                   mensajes,
                                                   pcgarant
                                                  );

                     IF vcpretip = 3 AND vesccero = 1
                     THEN
                        num_err :=
                           pac_albsgt.f_tprefor (vtprefor,
                                                 'EST',
                                                 ppoliza.det_poliza.sseguro,
                                                 pnriesgo,
                                                 pfefecto,
                                                 pnmovimi,
                                                 pcgarant,
                                                 v_resp,
                                                 1
                                                );
                     ELSE
                        /* Si no es un suplemento de alta de riesgo no se hace nada*/
                        IF (    v_cont_est <= v_cont_rea
                            AND v_cont_est_gar <= v_cont_gar
                           )
                        THEN
                           RETURN (0);
                        ELSE
                           w_pas_exec := 72;
                           num_err :=
                              pac_albsgt.f_tprefor
                                                 (vtprefor,
                                                  'EST',
                                                  ppoliza.det_poliza.sseguro,
                                                  pnriesgo,
                                                  pfefecto,
                                                  pnmovimi,
                                                  pcgarant,
                                                  v_resp,
                                                  1
                                                 );
                        END IF;
                     /* BUG12215:DRA:01/12/2009:fi*/
                     END IF;
                  ELSE
                     w_pas_exec := 73;
                     num_err :=
                        pac_albsgt.f_tprefor (vtprefor,
                                              'EST',
                                              ppoliza.det_poliza.sseguro,
                                              pnriesgo,
                                              pfefecto,
                                              pnmovimi,
                                              pcgarant,
                                              v_resp,
                                              1
                                             );
                  END IF;

                  w_pas_exec := 8;

                  --bartolo herrera
                  IF preg (i).cpregun = 2701
                  THEN
                     SELECT COUNT (*)
                       INTO cant_preg
                       FROM estpregunpolseg
                      WHERE sseguro =
                                  pac_iax_produccion.poliza.det_poliza.sseguro
                        AND nmovimi =
                                  pac_iax_produccion.poliza.det_poliza.nmovimi
                        AND cpregun = 2913;

                     IF cant_preg = 0
                     THEN                         -- si no escogio un convenio
                        v_resp := 0;
                        preg (i).crespue := 0;
                     END IF;
                  END IF;

                  --bartolo herrera
                  IF preg (i).crespue IS NULL AND preg (i).trespue IS NULL
                  /*Bug 31686/180437 - 24/07/2014 - AMC*/
                  THEN
                     preg (i).crespue := v_resp;

                     /*Inici BUG 29315 - RCL - 06/02/2014*/
                     BEGIN
                        SELECT ctippre
                          INTO v_ctippre
                          FROM codipregun
                         WHERE cpregun = preg (i).cpregun;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_ctippre := 0;
                     END;

                     IF v_ctippre = 4
                     THEN
                        /*PREGUNTA DE TIPUS DATA*/
                        preg (i).trespue := TO_CHAR (v_resp, '09999999');
                     ELSE
                        preg (i).trespue := TO_CHAR (v_resp);
                     END IF;
                  /*Fi BUG 29315 - RCL - 06/02/2014*/
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      /* Bug 9858 - RSC - 28/04/2009 - Fin*/
      w_pas_exec := 9;

      IF pcgarant IS NULL
      THEN
         /* Grabamos de nuevo las preguntas en el ob_iax_riesgos de la coleccción*/
         /* riesgos del objeto poliza*/
         w_err :=
            pac_iobj_prod.f_set_partriespreguntas (ppoliza.det_poliza,
                                                   pnriesgo,
                                                   preg,
                                                   mensajes
                                                  );

         IF w_err <> 0
         THEN
            w_pas_exec := 10;
            RAISE e_object_error;
         END IF;
      ELSE
         w_err :=
            pac_iobj_prod.f_set_partgarpreguntas (ppoliza.det_poliza,
                                                  pnriesgo,
                                                  pcgarant,
                                                  preg,
                                                  mensajes
                                                 );

         IF w_err <> 0
         THEN
            w_pas_exec := 11;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN (0);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000005,
                                            w_pas_exec,
                                            w_param
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000006,
                                            w_pas_exec,
                                            w_param
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000001,
                                            w_pas_exec,
                                            w_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (1);
   END f_grabar_semiautomatriesgo;

   /*************************************************************************
    Establece las preguntas asignadas al producto para insertalas en la poliza
    param in pnmovimi  :    código de movimiento
    param in out pregs :    mensajes de error
    param in out mensajes : mensajes de error
    return             :    NUMBER
   *************************************************************************/
   /* Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomáticas*/
   FUNCTION p_set_pregunprod (
      pnmovimi   IN       NUMBER,
      pregs      IN OUT   t_iax_preguntas,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      pregp        t_iaxpar_preguntas;
      det_poliza   ob_iax_detpoliza;
      nerr         NUMBER             := -1;
      vpasexec     NUMBER (8)         := 1;
      vparam       VARCHAR2 (300)     := 'pnmovimi = ' || pnmovimi;
      vobject      VARCHAR2 (200)     := 'PAC_MD_PRODUCCION.p_set_pregunprod';
      vpos         NUMBER;

      FUNCTION existpreg (cpregun IN NUMBER)
         RETURN NUMBER
      IS
      BEGIN
         IF pregs IS NULL
         THEN
            RETURN -1;
         END IF;

         IF pregs.COUNT = 0
         THEN
            RETURN -1;
         END IF;

         FOR vpreg IN pregs.FIRST .. pregs.LAST
         LOOP
            IF pregs.EXISTS (vpreg)
            THEN
               IF pregs (vpreg).cpregun = cpregun
               THEN
                  RETURN vpreg;
               END IF;
            END IF;
         END LOOP;

         RETURN -1;
      END existpreg;
   BEGIN
      IF pregs IS NULL
      THEN
         pregs := t_iax_preguntas ();
      END IF;

      vpasexec := 1;
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        32332,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      pregp := pac_iaxpar_productos.f_get_pregpoliza (mensajes);

      IF pregp IS NOT NULL
      THEN
         vpasexec := 11;

         IF pregp.COUNT > 0
         THEN
            vpasexec := 12;

            FOR i IN pregp.FIRST .. pregp.LAST
            LOOP
               vpasexec := 13;

               IF pregp.EXISTS (i)
               THEN
                  vpasexec := 14;
                  vpos := existpreg (pregp (i).cpregun);

                  IF vpos = -1
                  THEN
                     nerr := 0;
                     /* te canvis*/
                     vpasexec := 15;
                     pregs.EXTEND;
                     pregs (pregs.LAST) := ob_iax_preguntas ();
                     pregs (pregs.LAST).cpregun := pregp (i).cpregun;
                     pregs (pregs.LAST).nmovimi := pnmovimi;
                     pregs (pregs.LAST).nmovima := pnmovimi;
                     pregs (pregs.LAST).finiefe := det_poliza.gestion.fefecto;
                     pregs (pregs.LAST).crespue := NULL;
                     vpasexec := 16;
                  /* Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
                  ELSE
                     IF pregp (i).isaltac = 1
                     THEN
                        nerr := 0;
                     END IF;

                     /* Fin bug 22839*/

                     -- BUG42247:DRA:Inici
                     -- Si se viene de una simulación y tiene preguntas semiautomáticas,
                     --  muy posiblemente tenga que volver a calcular su respuesta, porque
                     --  en el traspaso de simulación a contratación, se han insertado en el
                     --  objeto, pero con sus respuestas a NULL. Se debe devolver un 0 para
                     --  que se recalculen estas respuestas
                     IF     pregp (i).cpretip = 3
                        AND pregs (vpos).crespue IS NULL
                        AND pregs (vpos).trespue IS NULL
                     THEN
                        nerr := 0;
                     END IF;
                  -- BUG42247:DRA:Fi
                  END IF;
               END IF;
            END LOOP;
         /* Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
         /*nerr := 0;   -- BUG 22839/0121036 - FAL - 19/09/2012*/
         /* Fin bug 22839*/
         END IF;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 2;
            RETURN 1;
         END IF;
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END p_set_pregunprod;

   /*************************************************************************
   Establece las preguntas asignadas al producto para insertalas en la poliza
   param in pnmovimi  :    código de movimiento
   param in out pregs :    mensajes de error
   param in out mensajes : mensajes de error
   return             :    NUMBER
   *************************************************************************/
   /* Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomáticas*/
   FUNCTION p_set_pregunriesgos (
      pnmovimi   IN       NUMBER,
      pregs      IN OUT   t_iax_preguntas,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      pregp        t_iaxpar_preguntas;
      det_poliza   ob_iax_detpoliza;
      nerr         NUMBER             := -1;
      vpasexec     NUMBER (8)         := 1;
      vparam       VARCHAR2 (300)     := 'pnmovimi = ' || pnmovimi;
      vobject      VARCHAR2 (200)     := 'PAC_MD_PRODUCCION.p_set_pregunprod';

      FUNCTION existpreg (cpregun IN NUMBER)
         RETURN NUMBER
      IS
      BEGIN
         IF pregs IS NULL
         THEN
            RETURN -1;
         END IF;

         IF pregs.COUNT = 0
         THEN
            RETURN -1;
         END IF;

         FOR vpreg IN pregs.FIRST .. pregs.LAST
         LOOP
            IF pregs.EXISTS (vpreg)
            THEN
               IF pregs (vpreg).cpregun = cpregun
               THEN
                  RETURN vpreg;
               END IF;
            END IF;
         END LOOP;

         RETURN -1;
      END existpreg;
   BEGIN
      IF pregs IS NULL
      THEN
         pregs := t_iax_preguntas ();
      END IF;

      vpasexec := 1;
      det_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        32332,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      pregp := pac_iaxpar_productos.f_get_datosriesgos (mensajes);

      IF pregp IS NOT NULL
      THEN
         vpasexec := 11;

         IF pregp.COUNT > 0
         THEN
            vpasexec := 12;

            FOR i IN pregp.FIRST .. pregp.LAST
            LOOP
               vpasexec := 13;

               IF pregp.EXISTS (i)
               THEN
                  vpasexec := 14;

                  IF existpreg (pregp (i).cpregun) = -1
                  THEN
                     nerr := 0;
                     /* te canvis*/
                     vpasexec := 15;
                     pregs.EXTEND;
                     pregs (pregs.LAST) := ob_iax_preguntas ();
                     pregs (pregs.LAST).cpregun := pregp (i).cpregun;
                     pregs (pregs.LAST).nmovimi := pnmovimi;
                     pregs (pregs.LAST).nmovima := pnmovimi;
                     pregs (pregs.LAST).finiefe := det_poliza.gestion.fefecto;
                     pregs (pregs.LAST).crespue := NULL;
                     pregs (pregs.LAST).ctipgru := pregp (i).ctipgru;
                     vpasexec := 16;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 2;
            RETURN 1;
         END IF;
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END p_set_pregunriesgos;

   /*************************************************************************
   Recupera las pólizas de colectivos con certificado cero para el producto indicado
   param in psproduc  : código de producto
   param in pnpoliza  : num. poliza
   param in pbuscar  : texto a buscar por nombre de tomador
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   /* Bug 8745 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados*/
   FUNCTION f_get_certificadoscero (
      psproduc     IN       NUMBER,
      pnpoliza     IN       NUMBER,                  /*BUG11008-01092009-XPL*/
      pnsolici     IN       NUMBER,   /* Bug 34409/196980 - 16/04/2015 - POS*/
      pbuscar      IN       VARCHAR2,               /*BUG11008-01092009-XPL,*/
      pcintermed   IN       NUMBER,         /*BUG22839/125740:DCT:21/10/2012*/
      pcsucursal   IN       NUMBER,         /*BUG22839/125740:DCT:21/10/2012*/
      pcadm        IN       NUMBER,         /*BUG22839/125740:DCT:21/10/2012*/
      mensajes     IN OUT   t_iax_mensajes,
      pmodo        IN       VARCHAR2
            DEFAULT NULL              /* Bug 30360/174025 - 09/05/2014 - AMC*/
   )
      RETURN VARCHAR2
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
         :=    'psproduc: '
            || psproduc
            || 'pnpoliza: '
            || pnpoliza
            || 'pnsolici: '
            || pnsolici
            || 'pbuscar: '
            || pbuscar
            || 'pcintermed: '
            || pcintermed
            || 'pcsucursal: '
            || pcsucursal
            || 'pcadm: '
            || pcadm
            || 'pmodo: '
            || pmodo;
      vobject    VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.f_get_certificadoscero';
      squery     VARCHAR2 (3000);
      num_err    NUMBER;
   BEGIN
      squery :=
         pac_seguros.f_sel_certificadoscero
                              (psproduc,
                               pnpoliza,
                               pbuscar,
                               pcintermed,
                               pcsucursal,
                               pcadm,
                               /*BUG22839/125740:DCT:21/10/2012*/
                               pac_md_common.f_get_cxtidioma,
                               pmodo, /* Bug 30360/174025 - 09/05/2014 - AMC*/
                               pnsolici
                              );

      IF squery IS NULL
      THEN
         RAISE e_object_error;
      END IF;

      RETURN squery;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_certificadoscero;

   /*************************************************************************
      Obtiene datos gestion del certificado 0
      param out mensajes : mensajes de error
      return             : objeto datos gestion
   *************************************************************************/
   /* Bug 8745 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados*/
   FUNCTION f_get_datosgestion (
      ppoliza    IN       ob_iax_detpoliza,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN ob_iax_detpoliza
   IS
      obpoliza   ob_iax_detpoliza;
      nerr       NUMBER;
      vpasexec   NUMBER (8)       := 1;
      vparam     VARCHAR2 (1)     := NULL;
      vobject    VARCHAR2 (200)   := 'PAC_MD_PRODUCCION.F_get_DatosGestion';
      vcactivi   NUMBER;
   BEGIN
      obpoliza := ppoliza;
      /* Se busca el cactivi de la poliza con certificado 0*/
      nerr :=
         pac_seguros.f_get_cactivi (NULL, ppoliza.npoliza, 0, 'SEG',
                                    vcactivi);

      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      obpoliza.gestion.cactivi := vcactivi;
      RETURN obpoliza;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_datosgestion;

   /*************************************************************************
      Graba en el objeto poliza la distribución seleccionada
      param in pcmodelo  : Código de modelo de inversión
      param in ppoliza   : Objeto póliza
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   /* Bug 9031 - 11/03/2009 - RSC - AXIS: Análisis adaptación productos indexados*/
   FUNCTION f_grabar_modeloinvulk (
      pcmodelo   IN       NUMBER,
      ppoliza    IN OUT   ob_iax_poliza,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vtprefor     VARCHAR2 (100);
      v_resp       NUMBER;
      distr        ob_iax_produlkmodelosinv;
      num_err      NUMBER;
      vaux         NUMBER;

      CURSOR c_modelos (
         pcramo     NUMBER,
         pcmodali   NUMBER,
         pctipseg   NUMBER,
         pccolect   NUMBER
      )
      IS
         SELECT m.ccodfon, f.tfonabv, m.pinvers
           FROM modinvfondo m, fondos f
          WHERE cmodinv = pcmodelo
            AND m.ccodfon = f.ccodfon
            AND cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;

      w_err        PLS_INTEGER;
      w_pas_exec   PLS_INTEGER              := 1;
      w_param      VARCHAR2 (500)      := 'parametres: pcmodelo =' || pcmodelo;
      w_object     VARCHAR2 (200)    := 'PAC_MD_PRODUCCION.f_grabar_modeloinv';
   BEGIN
      IF ppoliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        -456,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_param_error;
      END IF;

      w_pas_exec := 2;

      /* Detalle del modelo de inversión*/
      FOR regs IN c_modelos (ppoliza.det_poliza.cramo,
                             ppoliza.det_poliza.cmodali,
                             ppoliza.det_poliza.ctipseg,
                             ppoliza.det_poliza.ccolect
                            )
      LOOP
         distr.cmodinv := pcmodelo;
         distr.modinvfondo := t_iax_produlkmodinvfondo ();
         distr.modinvfondo.EXTEND;
         distr.modinvfondo (distr.modinvfondo.LAST) :=
                                                 ob_iax_produlkmodinvfondo
                                                                          ();
         distr.modinvfondo (distr.modinvfondo.LAST).ccodfon := regs.ccodfon;
         distr.modinvfondo (distr.modinvfondo.LAST).tcodfon := regs.tfonabv;
         distr.modinvfondo (distr.modinvfondo.LAST).pinvers := regs.pinvers;
      END LOOP;

      w_pas_exec := 3;
      /* Grabamos de nuevo la distribucion en el objeto póliza*/
      ppoliza.det_poliza.modeloinv := distr;
      RETURN (0);
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000001,
                                            w_pas_exec,
                                            w_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (1);
   END f_grabar_modeloinvulk;

   /*************************************************************************
      Obtiene info de si una garantÃ­a está o no contratada
      param in psseguro : identificador de seguro
      param in pcgarant : identificador de garantÃ­a
      param out mensajes : mensajes de error
      return             : objeto datos gestion
   *************************************************************************/
   /* Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima*/
   FUNCTION f_get_contagar (psseguro IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER
   IS
      v_num_gar   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_num_gar
        FROM garanseg g, estseguros s
       WHERE s.sseguro = psseguro
         AND s.ssegpol = g.sseguro
         AND g.cgarant = pcgarant
         AND g.ffinefe IS NULL;

      RETURN (v_num_gar);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (NULL);
   END f_get_contagar;

   /* Bug 12136 - 24/03/2010 - JRH - 0012136: CEM - RVI - Verificación productos RVI*/
   /*************************************************************************
   Establece el valor del pdoscab
   informados los datos no hace nada
   param in pgest  : datos de gestión
   param out       : mensajes de error
   return          : 0 todo correcto
                    1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_pctrev (
      pgest      IN OUT   ob_iax_gestion,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vries         t_iax_riesgos;
      vnerr         NUMBER;
      vdet_poliza   ob_iax_detpoliza;
      vpasexec      NUMBER (8)                     := 1;
      vparam        VARCHAR2 (500)         := 'parámetros - datos de gestión';
      vobject       VARCHAR2 (200)        := 'PAC_MD_PRODUCCION.f_set_pctrev';
      vtablaaseg    t_iax_asegurados;
      vcpctrev      producto_ren.cpctrev%TYPE;
      vnpctrev      producto_ren.npctrev%TYPE;
      vnpctrevmin   producto_ren.npctrevmin%TYPE;
      vnpctrevmax   producto_ren.npctrevmax%TYPE;
   BEGIN
      vnerr := 0;
      vpasexec := 0;
      vdet_poliza := pac_iobj_prod.f_getpoliza (mensajes);

      IF vdet_poliza IS NULL
      THEN
         pac_iobj_mensajes.p_grabadberror
                                      (vobject,
                                       2,
                                       'No puede recuperar el objeto poliza',
                                       'vdeT_poliza'
                                      );
         RETURN 0;
      END IF;

      vpasexec := 1;

      IF NVL (f_parproductos_v (vdet_poliza.sproduc, 'ES_PRODUCTO_RENTAS'), 0) =
                                                                             0
      THEN
         /*JRH Si no es un producto de rentas no ha de validarse*/
         RETURN 0;
      END IF;

      vpasexec := 2;
      vries := pac_iobj_prod.f_partpolriesgos (vdet_poliza, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 2;
            RAISE e_object_error;
         END IF;
      END IF;

      /* Bug 13969 - 30/03/2010 - JRH - 0013969: Si no falla las simulaciones*/
      IF vries IS NULL OR vries.COUNT = 0
      THEN
         RETURN 0;
      END IF;

      /* Fi Bug 13969 - 30/03/2010*/
      vpasexec := 3;
      vtablaaseg := vries (1).riesgoase;
      vpasexec := 4;

      IF vtablaaseg IS NULL OR vtablaaseg.COUNT = 0
      THEN
         RETURN 0;
      END IF;

      IF vtablaaseg IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               1,
                                               4567,
                                               'No existen asegurados'
                                              );
         vpasexec := 5;
         RAISE e_object_error;
      END IF;

      SELECT cpctrev, npctrev, npctrevmin, npctrevmax
        INTO vcpctrev, vnpctrev, vnpctrevmin, vnpctrevmax
        FROM producto_ren
       WHERE sproduc = vdet_poliza.sproduc;

      IF vtablaaseg.COUNT < 2
      THEN
         pgest.pdoscab := 0;                 /*Para una cabeza el pdoscab=0*/
      ELSE
         IF NVL (pgest.pdoscab, 0) = 0
         THEN
            /*Para dos cabezaa , si el pdoscab no está informado, le ponemos el valor por defecto*/
            IF vcpctrev = 1
            THEN
               pgest.pdoscab := vnpctrev;
            ELSIF vcpctrev = 2
            THEN
               pgest.pdoscab := vnpctrev;               /*Valor por defecto*/
            END IF;
         END IF;
      END IF;

      RETURN vnerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_set_pctrev;

   /* Fi Bug 12136 - 24/03/2010 - JRH*/
   /*************************************************************************
      Recupera la direccion del tomador
      param in ptomador
      param out  psitriesgo
      param out mensajes  : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error

      Bug 14443 - 12/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_domicili_prenedor (
      ptomador     IN       t_iax_tomadores,
      psitriesgo   OUT      ob_iax_sitriesgos,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      ries        t_iax_riesgos;
      vparam      VARCHAR2 (200);
      vpasexec    NUMBER (8)        := 1;
      vobject     VARCHAR2 (200)
                               := 'PAC_MD_PRODUCCION.f_get_domicili_prenedor';
      vnumerr     NUMBER;
      direccion   ob_iax_sitriesgos := ob_iax_sitriesgos ();
      ptablas     VARCHAR2 (10)     := 'EST';
      numdir      NUMBER;
   BEGIN
      IF ptomador IS NOT NULL
      THEN
         IF ptomador.COUNT > 0
         THEN
            IF ptomador (ptomador.LAST).direcciones IS NOT NULL
            THEN
               IF ptomador (ptomador.LAST).direcciones.COUNT > 0
               THEN
                  numdir :=
                     ptomador (ptomador.LAST).direcciones
                                    (ptomador (ptomador.LAST).direcciones.LAST
                                    ).cdomici;
               ELSE
                  numdir := 1;
               END IF;
            ELSE
               numdir := 1;
            END IF;

            BEGIN
               SELECT tdomici, csiglas,
                      tnomvia, nnumvia,
                      tcomple, cpostal,
                      cpoblac, tpoblac,
                      cprovin, tprovin, cpais,
                      tpais
                 INTO direccion.tdomici, direccion.csiglas,
                      direccion.tnomvia, direccion.nnumvia,
                      direccion.tcomple, direccion.cpostal,
                      direccion.cpoblac, direccion.tpoblac,
                      direccion.cprovin, direccion.tprovin, direccion.cpais,
                      direccion.tpais
                 FROM (SELECT tdomici, csiglas, tnomvia, nnumvia, tcomple,
                              cpostal, cpoblac,
                              f_despoblac2 (cpoblac, p.cprovin) tpoblac,
                              p.cprovin, p.tprovin, p.cpais,
                              ff_despais
                                      (p.cpais,
                                       pac_md_common.f_get_cxtidioma ()
                                      ) tpais
                         /* jtg*/
                       FROM   estper_direcciones d, provincias p
                        WHERE d.sperson = ptomador (ptomador.LAST).sperson
                          AND d.cdomici = numdir
                          AND p.cprovin(+) = d.cprovin
                          AND ptablas = 'EST'
                       UNION ALL
                       SELECT tdomici, csiglas, tnomvia, nnumvia, tcomple,
                              cpostal, cpoblac,
                              f_despoblac2 (cpoblac, p.cprovin) tpoblac,
                              p.cprovin, p.tprovin, p.cpais,
                              ff_despais
                                      (p.cpais,
                                       pac_md_common.f_get_cxtidioma ()
                                      ) tpais
                         /* jtg*/
                       FROM   per_direcciones d, provincias p
                        WHERE d.sperson = ptomador (ptomador.LAST).sperson
                          AND d.cdomici = numdir
                          AND p.cprovin(+) = d.cprovin
                          AND ptablas != 'EST');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN 1;
            END;
         ELSE
            RETURN 1;
         END IF;
      ELSE
         RETURN 1;
      END IF;

      vpasexec := 10;
      psitriesgo := direccion;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_domicili_prenedor;

   /*************************************************************************
       Determina si debe o no debe grabar objeto de tarificación
       param in pcmotmov
       param in out mensajes  : mensajes de error
       return                 : 0 todo correcto
                                1 ha habido un error
   *************************************************************************/
   /* Bug 13832 - RSC - 10/06/2010 -  APRS015 - suplemento de aportaciones únicas*/
   FUNCTION f_bloqueo_grabarobjectodb (
      psseguro   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam     VARCHAR2 (200);
      vpasexec   NUMBER (8)     := 1;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_PRODUCCION.f_bloqueo_grabarobjectodb';
      vres       NUMBER;
   BEGIN
      vres := pac_propio.f_bloqueo_grabarobjectodb (psseguro, pcmotmov);
      RETURN vres;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_bloqueo_grabarobjectodb;

   /*************************************************************************
      Borrar registros en las tablas est que dependen de la actividad que seleccionemos
      param in psolicit   : número de solicitud
      param in pnmovimi   : número de movimiento
      param in pnriesgo   : número de riesgo
      param in pcobjase   : tipo de riesgo
      param in ppmode   : Modo EST/POL
      param in out mensajes  : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error o codigo error
   *************************************************************************/
   PROCEDURE p_limpiar_tablas (
      psolicit   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcobjase   IN       NUMBER,
      ppmode     IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'parámetros - psolicit: '
            || psolicit
            || ' - pnriesgo: '
            || pnriesgo
            || ' - pnmovimi: '
            || pnmovimi
            || ' - pcobjase: '
            || pcobjase
            || ' - ppmode: '
            || ppmode;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.p_limpiar_tablas';
   BEGIN
      IF psolicit IS NULL OR pnriesgo IS NULL OR ppmode IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pac_alctr126.p_limpiar_tablas (psolicit,
                                     pnriesgo,
                                     pnmovimi,
                                     pcobjase,
                                     ppmode
                                    );
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
   END p_limpiar_tablas;

   /* Bug 16768 - APD - 22-11-2010 - se crea la funcion f_get_agentecol*/
   /***************************************************************************
      FUNCTION f_get_agentecol
      Dado un numero de poliza, obtenemos el codigo del agente de su certificado 0
         param in  pnpoliza:  numero de la póliza.
         return:              NUMBER.
   ***************************************************************************/
   FUNCTION f_get_agentecol (pnpoliza IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      vparam      VARCHAR2 (200);
      vpasexec    NUMBER (8)             := 1;
      vobject     VARCHAR2 (200)       := 'PAC_MD_PRODUCCION.f_get_agentecol';
      v_cagente   seguros.cagente%TYPE;
   BEGIN
      v_cagente := pac_seguros.f_get_agentecol (pnpoliza);
      RETURN v_cagente;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_agentecol;

   /* Fin Bug 16768 - APD - 22-11-2010*/
   /* Bug 16768 - APD - 22-11-2010 - se crea la funcion f_get_cforpagcol*/
   /***************************************************************************
      FUNCTION f_get_cforpagcol
      Dado un numero de poliza, obtenemos la forma de pago de su certificado 0
         param in  pnpoliza:  numero de la póliza.
         return:              NUMBER.
   ***************************************************************************/
   FUNCTION f_get_cforpagcol (
      pnpoliza   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam      VARCHAR2 (200);
      vpasexec    NUMBER (8)             := 1;
      vobject     VARCHAR2 (200)       := 'PAC_MD_PRODUCCION.f_get_agentecol';
      v_cagente   seguros.cagente%TYPE;
   BEGIN
      v_cagente := pac_seguros.f_get_cforpagcol (pnpoliza);
      RETURN v_cagente;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_cforpagcol;

   /* Fin Bug 16768 - APD - 22-11-2010*/
   /*************************************************************************
       FUNCTION f_grabargar_modifdb
       Determina si debe o no debe grabar el objeto garantÃ­as a BDD para el
       motivo de movimiento indicado.
       param in psseguro      : código del seguro
       param in pcmotmov      : motivo de movimiento
       param in out mensajes  : mensajes de error
       return                 : 0 no grabar el objeto
                                1 grabar el objeto
   *************************************************************************/
   /* Bug 17341 - 24/01/2011 - JMP - Se crea la función*/
   FUNCTION f_grabargar_modifdb (
      psseguro   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam     VARCHAR2 (200);
      vpasexec   NUMBER (8)     := 1;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_grabargar_modifdb';
      vres       NUMBER;
   BEGIN
      vres := pac_propio.f_grabargar_modifdb (psseguro, pcmotmov);
      RETURN vres;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_grabargar_modifdb;

   /*************************************************************************
    FUNCTION f_url_prodexterno
    Obtiene una url
    param in pproducto     : codigo producto
    param in ptipo         : tipo
    param in pidpoliza     : idpoliza
    param in out mensajes  : mensajes de error
    return                 : URL
   *************************************************************************/
   /* Bug 18058 - 28/03/2011 - JTS - Se crea la función*/
   FUNCTION f_url_prodexterno (
      pproducto   IN       NUMBER,
      ptipo       IN       VARCHAR2,
      pidpoliza   IN       VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      vparam     VARCHAR2 (200);
      vpasexec   NUMBER (8)     := 1;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_url_prodexterno';
      vres       VARCHAR2 (500);
   BEGIN
      vres := pac_propio.f_url_prodexterno (pproducto, ptipo, pidpoliza);

      IF vres IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9901933);
         RAISE e_object_error;
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_url_prodexterno;

   /*************************************************************************
      Recupera datos del riesgo por defecto
      param in pcempres
      param in pcobjase
      param in psproduc
      param in pcactivi
      param out psperson
      param out psperson
      param out  ptdomici
      param out  pcpais
      param out  pcprovin
      param out  pcpoblac
      param out  pcpostal
      param out  ptnatrie
      param out mensajes  : mensajes de error
      return              : 0 todo correcto
                            1 si ha habido un error

      Bug 17950 - 28/04/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_riesgo_defecto (
      pcempres    IN       NUMBER,
      pcobjase    IN       NUMBER,
      psproduc    IN       NUMBER,
      pcactivi    IN       NUMBER,
      psperson    OUT      NUMBER,
      ptdomici    OUT      VARCHAR2,
      pcpais      OUT      NUMBER,
      pcprovin    OUT      NUMBER,
      pcpoblac    OUT      NUMBER,
      pcpostal    OUT      VARCHAR2,
      ptnatrie    OUT      VARCHAR2,
      pcversion   OUT      VARCHAR2,
      pcmodelo    OUT      VARCHAR2,
      pcmarca     OUT      VARCHAR2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam     VARCHAR2 (200);
      vpasexec   NUMBER (8)     := 1;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_PRODUCCION.f_get_domicili_prenedor';
      vnumerr    NUMBER;
   BEGIN
      BEGIN
         SELECT sperson, tdomici, cpais, cprovin, cpoblac, cpostal,
                tnatrie, cversion, cmodelo, cmarca
           INTO psperson, ptdomici, pcpais, pcprovin, pcpoblac, pcpostal,
                ptnatrie, pcversion, pcmodelo, pcmarca
           FROM riesgo_defecto rd
          WHERE rd.cempres = pcempres
            AND rd.sproduc = psproduc
            AND rd.cactivi = pcactivi
            AND rd.cobjase = pcobjase;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT sperson, tdomici, cpais, cprovin, cpoblac,
                      cpostal, tnatrie, cversion, cmodelo, cmarca
                 INTO psperson, ptdomici, pcpais, pcprovin, pcpoblac,
                      pcpostal, ptnatrie, pcversion, pcmodelo, pcmarca
                 FROM riesgo_defecto rd
                WHERE rd.cempres = pcempres AND rd.cobjase = pcobjase;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN 1;
            END;
      END;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_riesgo_defecto;

   /*************************************************************************
      Emite la propuesta
      param in psolicit  : número solicitud
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error o codigo error
   --BUG18926 - JTS - 15/07/2011
   *************************************************************************/
   FUNCTION f_emitir (
      psseguro    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pissuplem   IN       BOOLEAN,
      onpoliza    OUT      NUMBER,
      mensajes    IN OUT   t_iax_mensajes,
      psproces    IN       NUMBER DEFAULT NULL,
      pcommit              NUMBER DEFAULT 1
   /* Bug 26070 - ECP- 21/02/2013*/
   )
      /* BUG23853:DRA:08/11/2012*/
   RETURN NUMBER
   IS
      osseguro   NUMBER;
      onmovimi   NUMBER;
      vnumerr    NUMBER;

      FUNCTION f_previo (
         psseguro   IN       NUMBER,
         pnmovimi   IN       NUMBER,
         onpoliza   OUT      NUMBER,
         mensajes   IN OUT   t_iax_mensajes
      )
         RETURN NUMBER
      IS
         vnumerr          NUMBER (8);
         vterror          VARCHAR2 (1000);
         vcreteni         NUMBER;
         vvsseguro        NUMBER;
         vcempres         NUMBER;
         vnpoliza         NUMBER;
         vncertif         NUMBER;
         vcramo           NUMBER;
         vcmodali         NUMBER;
         vctipseg         NUMBER;
         vccolect         NUMBER;
         vcactivi         NUMBER;
         vcidioma         NUMBER;
         vsproduc         seguros.sproduc%TYPE;
         vttext           VARCHAR2 (1000);
         indice           NUMBER (8);
         indice_e         NUMBER (8);
         v_cmotret        NUMBER (8);
         vtmsg            VARCHAR2 (500);
         vpasexec         NUMBER (8)             := 1;
         vparam           VARCHAR2 (200)
            :=    'psseguro: '
               || psseguro
               || ' - pnmovimi: '
               || pnmovimi
               || ' - onpoliza: '
               || onpoliza;
         vobject          VARCHAR2 (200)       := 'PAC_MD_PRODUCCION.f_emitir';
         v_tipo_fefecto   VARCHAR2 (2);
         v_csituac        NUMBER (2);
         v_nmovimi        NUMBER (4);
         /* BUG9329:DRA:09/06/2009*/
         vparampsu        NUMBER;

         /* Fin Bug 8745*/
         CURSOR c_rie (
            pcsseguro   IN   seguros.sseguro%TYPE,
            pctablas    IN   VARCHAR2
         )
         IS
            SELECT nriesgo
              FROM riesgos
             WHERE sseguro = pcsseguro AND pctablas IS NULL
            UNION ALL
            SELECT nriesgo
              FROM estriesgos
             WHERE sseguro = pcsseguro AND pctablas = 'EST';
      BEGIN
         /*Comprovació de parÃ metres d'entrada*/
         IF psseguro IS NULL OR pnmovimi IS NULL
         THEN
            RAISE e_param_error;
         END IF;

         /*Comprovem l'estat en que es troba la proposta*/
         vnumerr :=
                 pac_gestion_retenidas.f_estado_propuesta (psseguro, vcreteni);

         IF vnumerr <> 0
         THEN
            /*Error recuperant el tipus de retenció de la pólissa.*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 3;

         /*Actuem segons l'estat de la proposta*/
         IF vcreteni = 2
         THEN
            /*Proposta pendent d'autorització => No es pot emetre la proposta.*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 140598);
            RAISE e_object_error;
         ELSIF vcreteni IN (3, 4)
         THEN
            /*Proposta anulada o rebutjada => No es pot emetre la proposta.*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151177);
            RAISE e_object_error;
         ELSIF vcreteni = 1
         THEN
            vpasexec := 5;

            SELECT sproduc
              INTO vsproduc
              FROM seguros
             WHERE sseguro = psseguro;

            vparampsu := pac_parametros.f_parproducto_n (vsproduc, 'PSU');

            IF NVL (vparampsu, 0) = 0
            THEN
               /*Proposta retinguda => Abans d'emetre-la comprovem que no tingui errors en l'emissió*/
               FOR cr IN c_rie (psseguro, NULL)
               LOOP
                  vnumerr :=
                     pac_motretencion.f_risc_retingut (psseguro,
                                                       pnmovimi,
                                                       NVL (cr.nriesgo, 1),
                                                       5
                                                      );

                  IF vnumerr <> 0
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           151237
                                                          );
                     RAISE e_object_error;
                  END IF;
               END LOOP;

               vpasexec := 7;
               /*Com que es tractava d'una retenció voluntaria, l'acceptem.*/
               vttext :=
                      f_axis_literales (151726, pac_md_common.f_get_cxtidioma);
               vnumerr :=
                    pac_motretencion.f_desretener (psseguro, pnmovimi, vttext);

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            ELSE
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 1000129);
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 9;

         /*Obtenim les dades reals necesaries per emetre*/
         SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg,
                ccolect, cactivi, cidioma, sproduc, csituac
           INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg,
                vccolect, vcactivi, vcidioma, vsproduc, v_csituac
           FROM seguros
          WHERE sseguro = psseguro;

         vpasexec := 10;
         /* BUG 7701 - 3/2/2009 - DRA - Posiblemente se quiera poner la fecha de*/
         /* efecto del dÃ­a en que se emite la póliza*/
         /* Se recupera la fecha de efecto*/
         v_tipo_fefecto :=
                    NVL (f_parproductos_v (vsproduc, 'FEFECTO_PROP_RETEN'), 0);

         /* Bug 30779 - dlF - 15-IV-2014 - Problemas al emitir pólizas autorizadas previamente*/
         IF v_tipo_fefecto IN (3, 4) AND v_csituac = 4
         THEN
            /* fin Bug 30779 - dlF - 15-IV-2014*/
            vnumerr :=
               pac_seguros.f_set_fefecto (psseguro,
                                          TRUNC (f_sysdate),
                                          pnmovimi
                                         );

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 11;
         /*Emissió de la pólissa.*/
         /*TrapÃ s de la pólissa a les taules EST, per poder emetre la pólissa.*/
         pac_alctr126.traspaso_tablas_seguros (psseguro, vterror);

         IF vterror IS NOT NULL
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, NULL, vterror);
            RAISE e_object_error;
         END IF;

         vpasexec := 12;

         SELECT e.sseguro
           INTO vvsseguro
           FROM estseguros e
          WHERE e.ssegpol = psseguro AND ROWNUM = 1;

         /*//ACC per treure*/
         /* Bug 30779 - dlF - 15-IV-2014 - Problemas al emitir pólizas autorizadas previamente*/
         IF v_tipo_fefecto IN (3, 4) AND v_csituac = 4
         THEN
            /* fin Bug 30779 - dlF - 15-IV-2014*/
            vpasexec := 13;

            FOR rie IN c_rie (psseguro, 'EST')
            LOOP
               vnumerr :=
                  pac_md_produccion.f_tarifar_riesgo_tot ('EST',
                                                          vvsseguro,
                                                          rie.nriesgo,
                                                          pnmovimi,
                                                          TRUNC (f_sysdate),
                                                          mensajes
                                                         );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END LOOP;
         END IF;

         pac_iax_produccion.vsseguro := psseguro;
         pac_iax_produccion.vnmovimi := pnmovimi;

         SELECT sseguro
           INTO pac_iax_produccion.vsolicit
           FROM estseguros
          WHERE ssegpol = psseguro AND ROWNUM = 1;

         RETURN 0;
      EXCEPTION
         WHEN e_param_error
         THEN
            ROLLBACK;
            pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                               vobject,
                                               1000005,
                                               vpasexec,
                                               vparam
                                              );
            RETURN 1;
         WHEN e_object_error
         THEN
            ROLLBACK;
            pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                               vobject,
                                               1000006,
                                               vpasexec,
                                               vparam
                                              );
            RETURN 1;
         WHEN OTHERS
         THEN
            ROLLBACK;
            pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                               vobject,
                                               1000001,
                                               vpasexec,
                                               vparam,
                                               psqcode      => SQLCODE,
                                               psqerrm      => SQLERRM
                                              );
            RETURN 1;
      END f_previo;
   BEGIN
      IF pnmovimi > 1
      THEN
         vnumerr := f_previo (psseguro, pnmovimi, onpoliza, mensajes);

         IF vnumerr = 0
         THEN
            vnumerr :=
               pac_md_suplementos.f_emitir_suplemento
                                                (pac_iax_produccion.vsolicit,
                                                 psseguro,
                                                 TRUE,
                                                 onmovimi,
                                                 onpoliza,
                                                 osseguro,
                                                 mensajes,
                                                 pcommit
                                                );
         /*  Bug 26070 -- ECP-- 21/02/2013*/
         END IF;
      ELSE
         vnumerr :=
            f_emitirpropuesta (psseguro,
                               pnmovimi,
                               onpoliza,
                               mensajes,
                               psproces
                              );
      END IF;

      IF vnumerr <> 0
      THEN
         RETURN vnumerr;
      END IF;

      /* I - 31/10/2012 jlb - 23823*/
      /* Llamo a las listas restringidas*/
      /* Accion: anulaci??e p??a*/
      vnumerr :=
         pac_listarestringida.f_valida_listarestringida (psseguro,
                                                         NVL (pnmovimi, 1),
                                                         NULL,
                                                         4,
                                                         NULL,
                                                         NULL,
                                                         NULL
                                                        /* Bug 31411/175020 - 16/05/2014 - AMC*/
                                                        );

      IF vnumerr <> 0
      THEN
         RETURN vnumerr;
      END IF;

      vnumerr :=
         pac_listarestringida.f_valida_listarestringida (psseguro,
                                                         NVL (pnmovimi, 1),
                                                         NULL,
                                                         5,
                                                         NULL,
                                                         NULL,
                                                         NULL
                                                        /* Bug 31411/175020 - 16/05/2014 - AMC*/
                                                        );

      IF vnumerr <> 0
      THEN
         RETURN vnumerr;
      END IF;

      /* F - 31/10/2012- jlb - 23823*/
      RETURN vnumerr;
   END f_emitir;

   /*************************************************************************
   F_LEEDOCREQUERIDA
   Devuelve un objeto T_IAX_DOCREQUERIDA con la documentación requerida para los parametros informados.
   param in psproduc                : id de producto
   param in psseguro                : número secuencial de seguro
   param in pcactivi                : id de actividad
   param in pnmovimi                : número de movimiento
   param in pcidioma                : id de idioma
   param in out mensajes            : mensajes de error
   return                           : el objeto T_IAX_DOCREQUERIDA
   BUG 18351 - 10/05/2011 - JMP - Se crea la función   *************************************************************************/
   FUNCTION f_leedocrequerida (
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcidioma   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_docrequerida
   IS
      v_error       axis_literales.slitera%TYPE;
      v_pasexec     NUMBER (3)                       := 1;
      v_object      VARCHAR2 (200)   := 'PAC_MD_PRODUCCION.f_leedocrequerida';
      v_param       VARCHAR2 (200)
         :=    'psproduc: '
            || psproduc
            || ' - psseguro: '
            || psseguro
            || ' - pcactivi: '
            || pcactivi
            || ' - pnmovimi: '
            || pnmovimi
            || ' - pcidioma: '
            || pcidioma;
      vt_docreq     t_iax_docrequerida               := t_iax_docrequerida ();
      vob_docreq    ob_iax_docrequerida;
      sw_insertar   BOOLEAN                          := TRUE;
      v_result      NUMBER (1);
      /* Bug 27923/151007 - 04/09/2013 - AMC*/
      v_cdocreq     NUMBER;
      vselect       VARCHAR2 (1000);
      vrespuestas   sys_refcursor;
      vsseguro      NUMBER;
      vcpregun      NUMBER;
      vnmovimi      NUMBER;
      vnlinea       NUMBER;
      vccolumna     VARCHAR2 (50);
      vtvalor       VARCHAR2 (250);
      vfvalor       DATE;
      vnvalor       NUMBER;
      trobat        BOOLEAN;
      obligat       BOOLEAN;
      vnpoliza      NUMBER;
      vcount        NUMBER;
      vctipdoc      doc_docurequerida.ctipdoc%TYPE;
      /* Bug: 27923/155724 - JSV - 14/10/2013*/
      piddoc        NUMBER;                         /*RCL - Bug 28263/155705*/

      /* Fi Bug 27923/151007 - 04/09/2013 - AMC*/
      --Ini IAXIS-3634: -- ECP -- 26/04/2019
      CURSOR c_docrequerida
      IS
         SELECT DISTINCT e.seqdocu, NVL (e.cdocume, d.cdocume) cdocume,
                         d.sproduc, d.cactivi, d.norden, d.cclase,
                         DECODE (e.cdocume,
                                 NULL, dd.ttitdoc,
                                 DECODE (e.tfilename,
                                         NULL, DECODE (e.adjuntado,
                                                       1,  dd.ttitdoc
                                                        || ' - '
                                                        || dd.ttitdoc,
                                                       dd.ttitdoc
                                                      ),
                                         dd.ttitdoc || ' - ' || e.tdescrip
                                        )
                                ) tdescrip,
                         
                         /* BUG21710:DRA:28/03/2012*/
                         NVL (e.ctipdoc, d.ctipdoc) ctipdoc, d.tfuncio,
                         e.tfilename, NVL (e.adjuntado, 0) adjuntado,
                         NULL nriesgo, NULL ninqaval, NULL ctipo,
                         NULL sperson, NULL ctipben
                    FROM doc_docurequerida d,
                         doc_desdocumento dd,
                         estseguros s,
                         estdocrequerida e
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = d.sproduc
                     AND d.sproduc = psproduc
                     --AND d.cactivi = pcactivi
                     AND e.sseguro(+) = psseguro
                     AND e.cdocume(+) = d.cdocume
                     AND e.ctipdoc(+) = d.ctipdoc
                     /*BUG 30448/169525 - RCL - 21/03/2014*/
                     AND e.norden(+) = d.norden
                     AND e.nmovimi(+) =
                                   NVL (pnmovimi, pac_iax_produccion.vnmovimi)
                     AND d.cclase = 1                              /* poliza*/
                     AND d.cdocume = dd.cdocume
                     AND dd.cidioma = pcidioma
                     AND (   d.cmotmov IN (
                                SELECT DISTINCT cmotmov
                                           FROM estdetmovseguro
                                          WHERE sseguro = psseguro
                                            AND nmovimi =
                                                   NVL
                                                      (pnmovimi,
                                                       pac_iax_produccion.vnmovimi
                                                      ))   /* en suplementos*/
                          OR (d.cmotmov IN (
                                 SELECT DISTINCT cmotmov
                                            FROM detmovseguro
                                           WHERE sseguro = s.ssegpol
                                             AND nmovimi =
                                                    NVL
                                                       (pnmovimi,
                                                        pac_iax_produccion.vnmovimi
                                                       ))
                             )                /* En propuestas de suplemento*/
                          OR (    d.cmotmov = 100
                              AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) =
                                                                             1
                             )
                          /* nueva produccion o propuestas de alta*/
                          OR (    d.cmotmov = 0
                              AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <>
                                                                             1
                              AND EXISTS (
                                     (SELECT 1
                                        FROM estdetmovseguro
                                       WHERE sseguro = psseguro
                                         AND nmovimi =
                                                NVL
                                                   (pnmovimi,
                                                    pac_iax_produccion.vnmovimi
                                                   )
                                         AND cmotmov NOT IN (
                                                   SELECT cmotmov
                                                     FROM doc_docurequerida dd
                                                    WHERE dd.sproduc =
                                                                      psproduc
                                                                              --AND dd.cactivi = pcactivi
                                             )))
                             )
                          OR (    d.cmotmov = 0
                              AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <>
                                                                             1
                              AND 0 =
                                     (SELECT COUNT (*)
                                        FROM estdetmovseguro
                                       WHERE sseguro = psseguro
                                         AND nmovimi =
                                                NVL
                                                   (pnmovimi,
                                                    pac_iax_produccion.vnmovimi
                                                   ))
                             )
                         )
         UNION
         SELECT   e.seqdocu, NVL (e.cdocume, aux.cdocume) cdocume,
                  aux.sproduc, aux.cactivi, aux.norden, aux.cclase,
                  DECODE
                     (e.cdocume,
                      NULL,
                          /* Bug 24657/130885.NMM.2012.11.17. Afegim seqdocu*/
                          dd.ttitdoc
                       || ' - '
                       || f_axis_literales (100547, pcidioma)
                       || ' '
                       || aux.triesgo
                       || ' '
                       || aux.d_nom,
                      DECODE (e.tfilename,
                              NULL, DECODE (e.adjuntado,
                                            1,  dd.ttitdoc
                                             || ' - '
                                             || f_axis_literales (100547,
                                                                  pcidioma
                                                                 )
                                             || ' '
                                             || aux.triesgo
                                             || ' - '
                                             || dd.ttitdoc,
                                            dd.ttitdoc
                                           ),
                                 dd.ttitdoc
                              || ' - '
                              || f_axis_literales (100547, pcidioma)
                              || ' '
                              || aux.triesgo
                              || ' - '
                              || e.tdescrip
                             )
                     ) tdescrip,
                  
                  /* BUG21710:DRA:28/03/2012*/
                  NVL (e.ctipdoc, aux.ctipdoc) ctipdoc, aux.tfuncio,
                  e.tfilename, NVL (e.adjuntado, 0) adjuntado,
                  aux.nriesgo nriesgo, NULL ninqaval, NULL ctipo,
                  NULL sperson, NULL ctipben
             FROM estdocrequerida_riesgo e,
                  doc_desdocumento dd,
                  (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase,
                          d.ctipdoc, d.tfuncio, es.nriesgo,
                             ' '
                          || pp.tapelli1
                          || ' '
                          || pp.tapelli2
                          || ', '
                          || pp.tnombre d_nom,
                          DECODE
                             (es.sperson,         /* BUG21927:DRA:11/05/2012*/
                              NULL, es.tnatrie,
                                 pp.tapelli1
                              || ' '
                              || pp.tapelli2
                              || ', '
                              || pp.tnombre
                             ) triesgo,
                          d.cmotmov, s.ssegpol
                     FROM doc_docurequerida d,
                          estseguros s,
                          estriesgos es,
                          estper_detper pp
                    WHERE s.sseguro = psseguro
                      AND s.sproduc = d.sproduc
                      AND es.sseguro = s.sseguro
                      AND pp.sperson(+) = es.sperson
                      AND d.sproduc = psproduc
                      -- AND d.cactivi = pcactivi
                      AND d.cclase = 2                             /* Riesgo*/
                                      ) aux
            WHERE e.sseguro(+) = psseguro
              AND e.nriesgo(+) = aux.nriesgo
              AND e.cdocume(+) = aux.cdocume
              AND e.ctipdoc(+) = aux.ctipdoc
              /*BUG 30448/169525 - RCL - 21/03/2014*/
              AND e.norden(+) = aux.norden
              AND e.nmovimi(+) = NVL (pnmovimi, pac_iax_produccion.vnmovimi)
              AND dd.cdocume = aux.cdocume
              AND dd.cidioma = pcidioma
              AND (   aux.cmotmov IN (
                         SELECT DISTINCT cmotmov
                                    FROM estdetmovseguro
                                   WHERE sseguro = psseguro
                                     AND nriesgo = aux.nriesgo
                                     AND nmovimi =
                                            NVL (pnmovimi,
                                                 pac_iax_produccion.vnmovimi
                                                ))
                   OR (aux.cmotmov IN (
                          SELECT DISTINCT cmotmov
                                     FROM detmovseguro
                                    WHERE sseguro = aux.ssegpol
                                      AND nriesgo = aux.nriesgo
                                      AND nmovimi =
                                             NVL (pnmovimi,
                                                  pac_iax_produccion.vnmovimi
                                                 ))
                      )
                   OR (    aux.cmotmov = 100
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) = 1
                      )                                  /* nueva producción*/
                   OR (    aux.cmotmov = 0
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <> 1
                       AND EXISTS (
                              (SELECT 1
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi =
                                         NVL (pnmovimi,
                                              pac_iax_produccion.vnmovimi
                                             )
                                  AND cmotmov NOT IN (
                                                   SELECT cmotmov
                                                     FROM doc_docurequerida dd
                                                    WHERE dd.sproduc =
                                                                      psproduc
                                                                              --AND dd.cactivi = pcactivi
                                      )))
                      )
                   OR (    aux.cmotmov = 0
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <> 1
                       AND 0 =
                              (SELECT COUNT (*)
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi =
                                         NVL (pnmovimi,
                                              pac_iax_produccion.vnmovimi
                                             ))
                      )
                  )
         UNION
         SELECT   e.seqdocu, NVL (e.cdocume, aux.cdocume) cdocume,
                  aux.sproduc, aux.cactivi, aux.norden, aux.cclase,
                  DECODE (e.cdocume,
                          NULL, f_axis_literales (9903896, pcidioma)
                           || ': '
                           || aux.triesgo
                           || ' - '
                           || dd.ttitdoc,
                          DECODE (e.tfilename,
                                  NULL, f_axis_literales (9903896, pcidioma)
                                   || ': '
                                   || aux.triesgo
                                   || ' - '
                                   || dd.ttitdoc,
                                     f_axis_literales (9903896, pcidioma)
                                  || ': '
                                  || aux.triesgo
                                  || ' - '
                                  || dd.ttitdoc
                                  || ' - '
                                  || e.tdescrip
                                 )
                         ) tdescrip,
                  NVL (e.ctipdoc, aux.ctipdoc) ctipdoc, aux.tfuncio,
                  e.tfilename, NVL (e.adjuntado, 0) adjuntado,
                  aux.nriesgo nriesgo, aux.nriesgo ninqaval, NULL ctipo,
                  aux.sperson sperson, NULL ctipben
             FROM estdocrequerida_inqaval e,
                  doc_desdocumento dd,
                  (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase,
                          d.ctipdoc, d.tfuncio, es.nriesgo,
                             pp.tapelli1
                          || ' '
                          || pp.tapelli2
                          || ', '
                          || pp.tnombre triesgo,
                          d.cmotmov, s.ssegpol, es.ctipfig, es.sperson
                     FROM doc_docurequerida d,
                          estseguros s,
                          estinquiaval es,
                          estper_detper pp
                    WHERE s.sseguro = psseguro
                      AND s.sproduc = d.sproduc
                      AND es.sseguro = s.sseguro
                      AND pp.sperson(+) = es.sperson
                      AND d.sproduc = psproduc
                      --AND d.cactivi = pcactivi
                      AND es.ctipfig = 1
                      AND d.cclase = 3                          /* Inquilino*/
                                      ) aux
            WHERE e.sseguro(+) = psseguro
              AND e.ninqaval(+) = aux.nriesgo
              AND e.cdocume(+) = aux.cdocume
              AND e.ctipdoc(+) = aux.ctipdoc
              /*BUG 30448/169525 - RCL - 21/03/2014*/
              AND e.norden(+) = aux.norden
              AND e.nmovimi(+) = NVL (pnmovimi, pac_iax_produccion.vnmovimi)
              AND e.sperson(+) = aux.sperson
              AND dd.cdocume = aux.cdocume
              AND dd.cidioma = pcidioma
              AND (   aux.cmotmov IN (
                         SELECT DISTINCT cmotmov
                                    FROM estdetmovseguro
                                   WHERE sseguro = psseguro
                                     AND nriesgo = aux.nriesgo
                                     AND nmovimi =
                                            NVL (pnmovimi,
                                                 pac_iax_produccion.vnmovimi
                                                ))
                   OR (aux.cmotmov IN (
                          SELECT DISTINCT cmotmov
                                     FROM detmovseguro
                                    WHERE sseguro = aux.ssegpol
                                      AND nriesgo = aux.nriesgo
                                      AND nmovimi =
                                             NVL (pnmovimi,
                                                  pac_iax_produccion.vnmovimi
                                                 ))
                      )
                   OR (    aux.cmotmov = 100
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) = 1
                      )                                  /* nueva producción*/
                   OR (    aux.cmotmov = 0
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <> 1
                       AND EXISTS (
                              (SELECT 1
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi =
                                         NVL (pnmovimi,
                                              pac_iax_produccion.vnmovimi
                                             )
                                  AND cmotmov NOT IN (
                                                   SELECT cmotmov
                                                     FROM doc_docurequerida dd
                                                    WHERE dd.sproduc =
                                                                      psproduc
                                                                              -- AND dd.cactivi = pcactivi
                                      )))
                      )
                   OR (    aux.cmotmov = 0
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <> 1
                       AND 0 =
                              (SELECT COUNT (*)
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi =
                                         NVL (pnmovimi,
                                              pac_iax_produccion.vnmovimi
                                             ))
                      )
                  )
         UNION
         SELECT   e.seqdocu, NVL (e.cdocume, aux.cdocume) cdocume,
                  aux.sproduc, aux.cactivi, aux.norden, aux.cclase,
                  DECODE (e.cdocume,
                          NULL, f_axis_literales (9903897, pcidioma)
                           || ': '
                           || aux.triesgo
                           || ' - '
                           || dd.ttitdoc,
                          DECODE (e.tfilename,
                                  NULL, f_axis_literales (9903897, pcidioma)
                                   || ': '
                                   || aux.triesgo
                                   || ' - '
                                   || dd.ttitdoc,
                                     f_axis_literales (9903897, pcidioma)
                                  || ': '
                                  || aux.triesgo
                                  || ' - '
                                  || dd.ttitdoc
                                  || ' - '
                                  || e.tdescrip
                                 )
                         ) tdescrip,
                  
                  /* BUG21710:DRA:28/03/2012*/
                  NVL (e.ctipdoc, aux.ctipdoc) ctipdoc, aux.tfuncio,
                  e.tfilename, NVL (e.adjuntado, 0) adjuntado,
                  aux.nriesgo nriesgo, aux.nriesgo ninqaval, NULL ctipo,
                  aux.sperson, NULL ctipben
             FROM estdocrequerida_inqaval e,
                  doc_desdocumento dd,
                  (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase,
                          d.ctipdoc, d.tfuncio, es.nriesgo,
                             pp.tapelli1
                          || ' '
                          || pp.tapelli2
                          || ', '
                          || pp.tnombre triesgo,
                          d.cmotmov, s.ssegpol, es.ctipfig, es.sperson
                     FROM doc_docurequerida d,
                          estseguros s,
                          estinquiaval es,
                          estper_detper pp
                    WHERE s.sseguro = psseguro
                      AND s.sproduc = d.sproduc
                      AND es.sseguro = s.sseguro
                      AND pp.sperson(+) = es.sperson
                      AND d.sproduc = psproduc
                      --AND d.cactivi = pcactivi
                      AND es.ctipfig = 2
                      AND d.cclase = 4                           /* Avalista*/
                                      ) aux
            WHERE e.sseguro(+) = psseguro
              AND e.ninqaval(+) = aux.nriesgo
              AND e.cdocume(+) = aux.cdocume
              AND e.ctipdoc(+) = aux.ctipdoc
              /*BUG 30448/169525 - RCL - 21/03/2014*/
              AND e.norden(+) = aux.norden
              AND e.nmovimi(+) = NVL (pnmovimi, pac_iax_produccion.vnmovimi)
              AND e.sperson(+) = aux.sperson
              AND dd.cdocume = aux.cdocume
              AND dd.cidioma = pcidioma
              AND (   aux.cmotmov IN (
                         SELECT DISTINCT cmotmov
                                    FROM estdetmovseguro
                                   WHERE sseguro = psseguro
                                     AND nriesgo = aux.nriesgo
                                     AND nmovimi =
                                            NVL (pnmovimi,
                                                 pac_iax_produccion.vnmovimi
                                                ))
                   OR (aux.cmotmov IN (
                          SELECT DISTINCT cmotmov
                                     FROM detmovseguro
                                    WHERE sseguro = aux.ssegpol
                                      AND nriesgo = aux.nriesgo
                                      AND nmovimi =
                                             NVL (pnmovimi,
                                                  pac_iax_produccion.vnmovimi
                                                 ))
                      )
                   OR (    aux.cmotmov = 100
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) = 1
                      )                                  /* nueva producción*/
                   OR (    aux.cmotmov = 0
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <> 1
                       AND EXISTS (
                              (SELECT 1
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi =
                                         NVL (pnmovimi,
                                              pac_iax_produccion.vnmovimi
                                             )
                                  AND cmotmov NOT IN (
                                                   SELECT cmotmov
                                                     FROM doc_docurequerida dd
                                                    WHERE dd.sproduc =
                                                                      psproduc
                                                                              --AND dd.cactivi = pcactivi
                                      )))
                      )
                   OR (    aux.cmotmov = 0
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <> 1
                       AND 0 =
                              (SELECT COUNT (*)
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi =
                                         NVL (pnmovimi,
                                              pac_iax_produccion.vnmovimi
                                             ))
                      )
                  )
         UNION
         SELECT   e.seqdocu, NVL (e.cdocume, aux.cdocume) cdocume,
                  aux.sproduc, aux.cactivi, aux.norden, aux.cclase,
                  DECODE (e.cdocume,
                          NULL, f_axis_literales (9001911, pcidioma)
                           || ': '
                           || aux.triesgo
                           || ' - '
                           || dd.ttitdoc,
                          DECODE (e.tfilename,
                                  NULL, f_axis_literales (9001911, pcidioma)
                                   || ': '
                                   || aux.triesgo
                                   || ' - '
                                   || dd.ttitdoc,
                                     f_axis_literales (9001911, pcidioma)
                                  || ': '
                                  || aux.triesgo
                                  || ' - '
                                  || dd.ttitdoc
                                  || ' - '
                                  || e.tdescrip
                                 )
                         ) tdescrip,
                  NVL (e.ctipdoc, aux.ctipdoc) ctipdoc, aux.tfuncio,
                  e.tfilename, NVL (e.adjuntado, 0) adjuntado,
                  aux.nriesgo nriesgo, aux.nriesgo ninqaval, NULL ctipo,
                  aux.sperson sperson, aux.ctipben ctipben
             FROM estdocrequerida_benespseg e,
                  doc_desdocumento dd,
                  (SELECT d.cdocume, d.sproduc, d.cactivi, d.norden, d.cclase,
                          d.ctipdoc, d.tfuncio, es.nriesgo,
                             pp.tapelli1
                          || ' '
                          || pp.tapelli2
                          || ', '
                          || pp.tnombre triesgo,
                          d.cmotmov, s.ssegpol, es.sperson, es.ctipben
                     FROM doc_docurequerida d,
                          estseguros s,
                          estbenespseg es,
                          estper_detper pp
                    WHERE s.sseguro = psseguro
                      AND s.sproduc = d.sproduc
                      AND es.sseguro = s.sseguro
                      AND pp.sperson(+) = es.sperson
                      AND d.sproduc = psproduc
                      --AND d.cactivi = pcactivi
                      AND d.cclase = 5                       /* Beneficiario*/
                                      ) aux
            WHERE e.sseguro(+) = psseguro
              AND e.nriesgo(+) = aux.nriesgo
              AND e.cdocume(+) = aux.cdocume
              AND e.ctipdoc(+) = aux.ctipdoc
              /*BUG 30448/169525 - RCL - 21/03/2014*/
              AND e.norden(+) = aux.norden
              AND e.nmovimi(+) = NVL (pnmovimi, pac_iax_produccion.vnmovimi)
              AND e.sperson(+) = aux.sperson
              AND dd.cdocume = aux.cdocume
              AND dd.cidioma = pcidioma
              AND (   aux.cmotmov IN (
                         SELECT DISTINCT cmotmov
                                    FROM estdetmovseguro
                                   WHERE sseguro = psseguro
                                     AND nriesgo = aux.nriesgo
                                     AND nmovimi =
                                            NVL (pnmovimi,
                                                 pac_iax_produccion.vnmovimi
                                                ))
                   OR (aux.cmotmov IN (
                          SELECT DISTINCT cmotmov
                                     FROM detmovseguro
                                    WHERE sseguro = aux.ssegpol
                                      AND nriesgo = aux.nriesgo
                                      AND nmovimi =
                                             NVL (pnmovimi,
                                                  pac_iax_produccion.vnmovimi
                                                 ))
                      )
                   OR (    aux.cmotmov = 100
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) = 1
                      )                                  /* nueva producción*/
                   OR (    aux.cmotmov = 0
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <> 1
                       AND EXISTS (
                              (SELECT 1
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi =
                                         NVL (pnmovimi,
                                              pac_iax_produccion.vnmovimi
                                             )
                                  AND cmotmov NOT IN (
                                                   SELECT cmotmov
                                                     FROM doc_docurequerida dd
                                                    WHERE dd.sproduc =
                                                                      psproduc
                                                                              --AND dd.cactivi = pcactivi
                                      )))
                      )
                   OR (    aux.cmotmov = 0
                       AND NVL (pnmovimi, pac_iax_produccion.vnmovimi) <> 1
                       AND 0 =
                              (SELECT COUNT (*)
                                 FROM estdetmovseguro
                                WHERE sseguro = psseguro
                                  AND nmovimi =
                                         NVL (pnmovimi,
                                              pac_iax_produccion.vnmovimi
                                             ))
                      )
                  )
         ORDER BY norden;                               /* Otros suplementos*/
   --Fin IAXIS-3634: -- ECP -- 26/04/2019
   BEGIN
      FOR reg IN c_docrequerida
      LOOP
         vob_docreq := ob_iax_docrequerida ();
         vob_docreq.seqdocu := reg.seqdocu;
         vob_docreq.cdocume := reg.cdocume;
         vob_docreq.sproduc := reg.sproduc;
         vob_docreq.cactivi := reg.cactivi;
         vob_docreq.norden := reg.norden;
         /* Bug: 27923/155724 - JSV - 14/10/2013 - INI*/
         /*vob_docreq.ctipdoc := reg.ctipdoc;*/
         vctipdoc := reg.ctipdoc;
         v_error :=
            pac_docrequerida.f_docreq_col (psseguro,
                                           pnmovimi,
                                           psproduc,
                                           pcactivi,
                                           reg.cdocume,
                                           vctipdoc
                                          );
         vob_docreq.ctipdoc := vctipdoc;
         /* Bug: 27923/155724 - JSV - 14/10/2013 - FIN*/
         vob_docreq.cclase := reg.cclase;
         vob_docreq.sseguro := psseguro;
         vob_docreq.nmovimi := pnmovimi;
         vob_docreq.nriesgo := reg.nriesgo;
         vob_docreq.ninqaval := reg.ninqaval;
         vob_docreq.tdescrip := reg.tdescrip;

         /*Inici BUG 28263/155705 - RCL - 28/10/2013 -  LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM*/
         IF     NVL
                   (pac_parametros.f_parempresa_n
                                              (pac_md_common.f_get_cxtempresa,
                                               'BPM'
                                              ),
                    0
                   ) = 1
            AND NVL (pac_parametros.f_parproducto_n (psproduc, 'BPM_EMISION'),
                     0
                    ) <> 0
         THEN
            IF reg.cdocume IS NOT NULL
            THEN
               BEGIN
                  SELECT cbd.iddoc
                    INTO piddoc
                    FROM casos_bpm_doc cbd JOIN estcasos_bpmseg ecb
                         ON (    cbd.nnumcaso = ecb.nnumcaso
                             AND cbd.cempres = ecb.cempres
                            )
                   WHERE cbd.cempres = pac_md_common.f_get_cxtempresa
                     AND ecb.sseguro = psseguro
                     AND cbd.cdocume = reg.cdocume;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     piddoc := NULL;
               END;
            ELSE
               piddoc := NULL;
            END IF;

            IF piddoc IS NOT NULL
            THEN
               vob_docreq.tfilename := pac_axisgedox.f_get_filedoc (piddoc);

               IF vob_docreq.tfilename IS NOT NULL
               THEN
                  vob_docreq.adjuntado := 1;
               ELSE
                  vob_docreq.adjuntado := reg.adjuntado;
               END IF;

               v_error :=
                  pac_md_grabardatos.f_grabardocrequerida
                                                        (reg.seqdocu,
                                                         psproduc,
                                                         psseguro,
                                                         reg.cactivi,
                                                         pnmovimi,
                                                         reg.nriesgo,
                                                         reg.ninqaval,
                                                         reg.cdocume,
                                                         reg.ctipdoc,
                                                         reg.cclase,
                                                         reg.norden,
                                                         reg.tdescrip,
                                                         vob_docreq.tfilename,
                                                         vob_docreq.adjuntado,
                                                         reg.sperson,
                                                         reg.ctipben,
                                                         mensajes,
                                                         piddoc
                                                        );
            ELSE
               vob_docreq.tfilename := reg.tfilename;
            END IF;
         ELSE
            vob_docreq.tfilename := reg.tfilename;
            vob_docreq.adjuntado := reg.adjuntado;
         END IF;

         IF vob_docreq.tfilename IS NOT NULL
         THEN
            vob_docreq.adjuntado := 1;
         ELSE
            vob_docreq.adjuntado := reg.adjuntado;
         END IF;

         /*Fi BUG 28263/155705 - RCL - 28/10/2013 -  LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM*/
         vob_docreq.sperson := reg.sperson;
         vob_docreq.ctipben := reg.ctipben;

         /* Bug: 27923/155724 - JSV - 14/10/2013 - INI*/
         /* Bug 27923/151007 - 04/09/2013 - AMC*/
         /*IF NVL(pac_parametros.f_parproducto_n(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            v_error := pac_productos.f_get_herencia_col(psproduc, 18, v_cdocreq);

            IF NVL(v_cdocreq, 0) = 1 THEN
               SELECT npoliza
                 INTO vnpoliza
                 FROM estseguros
                WHERE sseguro = psseguro;

               SELECT COUNT(1)
                 INTO vcount
                 FROM seguros
                WHERE npoliza = vnpoliza
                  AND ncertif = 0;

               IF vcount > 0 THEN
                  SELECT sseguro
                    INTO vsseguro
                    FROM seguros
                   WHERE npoliza = vnpoliza
                     AND ncertif = 0;

                  vselect := pac_preguntas.f_respuestas_pregtabla('POL', vsseguro, NULL, 9092,
                                                                  NULL, pnmovimi, 'P');
               ELSE
                  vselect := pac_preguntas.f_respuestas_pregtabla('EST', psseguro, NULL, 9092,
                                                                  NULL, pnmovimi, 'P');
               END IF;

               vrespuestas := pac_md_listvalores.f_opencursor(vselect, mensajes);

               LOOP
                  FETCH vrespuestas
                   INTO vsseguro, vcpregun, vnmovimi, vnlinea, vccolumna, vtvalor, vfvalor,
                        vnvalor;

                  --Miramos si el valor de la primera columna coresponde con el cod. de la documentación
                  IF vccolumna = 1 THEN
                     IF vnvalor = reg.cdocume THEN
                        trobat := TRUE;
                     END IF;
                  END IF;

                  IF vccolumna = 3 THEN
                     IF trobat THEN
                        IF vnvalor = 1 THEN
                           vob_docreq.ctipdoc := 2;
                        ELSE
                           vob_docreq.ctipdoc := 1;
                        END IF;
                     END IF;

                     trobat := FALSE;
                  END IF;

                  EXIT WHEN vrespuestas%NOTFOUND;
               END LOOP;
            END IF;
         END IF;*/
         /* Bug: 27923/155724 - JSV - 14/10/2013 - FIN*/
         IF vob_docreq.ctipdoc = 1
         THEN
            vob_docreq.cobliga := 0;
            sw_insertar := TRUE;
         ELSIF vob_docreq.ctipdoc = 2
         THEN
            vob_docreq.cobliga := 1;
            sw_insertar := TRUE;
         ELSE
            v_error :=
               pac_albsgt.f_tval_docureq (reg.tfuncio,
                                          'EST',
                                          reg.cactivi,
                                          psseguro,
                                          pnmovimi,
                                          /* Ini Bug 24657 - MDS - 22/11/2012*/
                                          reg.nriesgo,
                                          reg.sperson,
                                          /* Fin Bug 24657 - MDS - 22/11/2012*/
                                          v_result
                                         );

            IF v_error <> 0
            THEN
               RAISE e_object_error;
            END IF;

            IF v_result = 1
            THEN
               IF vob_docreq.ctipdoc = 3
               THEN
                  vob_docreq.cobliga := 0;
               ELSIF vob_docreq.ctipdoc = 4
               THEN
                  vob_docreq.cobliga := 1;
               END IF;

               sw_insertar := TRUE;               /* BUG21710:DRA:20/03/2012*/
            ELSE
               sw_insertar := FALSE;

               /* BUG21710:DRA:28/03/2012:Inici*/
               IF reg.seqdocu IS NOT NULL
               THEN
                  DELETE FROM estdocrequerida
                        WHERE seqdocu = reg.seqdocu
                          AND sseguro = psseguro
                          AND nmovimi = pnmovimi;
               END IF;
            /* BUG21710:DRA:28/03/2012:Fi*/
            END IF;
         END IF;

         /* Fi Bug 27923/151007 - 04/09/2013 - AMC*/
         IF sw_insertar
         THEN
            vt_docreq.EXTEND;
            vt_docreq (vt_docreq.LAST) := vob_docreq;
         END IF;
      END LOOP;

      RETURN vt_docreq;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN vt_docreq;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN vt_docreq;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN vt_docreq;
   END f_leedocrequerida;

   /* BUG21467:DRA:01/03/2012:Inici*/
   FUNCTION f_get_datos_host (
      datpol     IN       ob_iax_int_datos_poliza,
      pregpol    IN       t_iax_int_preg_poliza,
      v_query1   OUT      VARCHAR2,                      /* INT_DATOS_POLIZA*/
      v_query2   OUT      VARCHAR2,                     /* INT_DATOS_PREGPOL*/
      v_query3   OUT      VARCHAR2,                     /* INT_DATOS_RIESGOS*/
      v_query4   OUT      VARCHAR2,                     /* INT_DATOS_PREGRIE*/
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      verror     NUMBER;
      vsinterf   NUMBER;
      cur        sys_refcursor;
      vobject    VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.f_get_datos_host';
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000);
      vsquery    VARCHAR2 (2000);
   BEGIN
      IF datpol IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      verror :=
         pac_md_con.f_get_datos_host (pac_md_common.f_get_cxtempresa,
                                      datpol,
                                      pregpol,
                                      vsinterf,
                                      mensajes
                                     );
      vpasexec := 2;

      IF verror <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      v_query1 :=
            'SELECT sinterf, npoliza, fpoliza, nsolici FROM int_datos_poliza WHERE sinterf = '
         || vsinterf;
      vpasexec := 4;
      v_query2 :=
            'SELECT sinterf, cpregun, crespue, trespue, ctipprg, cnivel FROM int_datos_preguntas WHERE sinterf = '
         || vsinterf
         || ' and cnivel = ''P''';
      vpasexec := 5;
      v_query3 :=
            'SELECT sinterf, nriesgo, triesgo FROM int_datos_riesgo WHERE sinterf = '
         || vsinterf;
      vpasexec := 6;
      v_query4 :=
            'SELECT sinterf, nriesgo, cpregun, crespue, trespue, ctipprg, cnivel FROM int_datos_preguntas WHERE sinterf = '
         || vsinterf
         || ' and cnivel = ''R''';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            verror,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN 140999;
   END f_get_datos_host;

   /* BUG21467:DRA:01/03/2012:Fi*/
   /*BUG 19484 - 19/10/2011 - JRB - Crear el cuadro facultativo*/
   /*************************************************************************
      Crea el cuadro facultativo
      param in psseguro  : código de póliza
      param in pnmovimi  : numero de movimiento
      param in pcreteni  : propuesta retenida
      param out mensajes : mensajes de error
      return             : 1 -> Creado correctamente. Devolverá objeto mensajes
                           con el número de cuadro
   *************************************************************************/
   FUNCTION f_crear_facul (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,                 /* BUG10464:DRA:16/06/2009*/
      pcreteni   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr       NUMBER (8);
      vcreteni      NUMBER;
      vpasexec      NUMBER (8)                := 1;
      vparam        VARCHAR2 (500)            := 'psseguro= ' || psseguro;
      vobject       VARCHAR2 (200)       := 'PAC_MD_PRODUCCION.F_Crear_Facul';
      oestsseguro   NUMBER;
      onmovimi      NUMBER;
      v_csituac     NUMBER;
      v_fefesup     DATE;
      v_cempres     estseguros.cempres%TYPE;
      v_moneda      NUMBER;
      vsproduc      productos.sproduc%TYPE;
      vsproces      NUMBER;
      lsproces      NUMBER;
      vterror       VARCHAR2 (1000);
      lmotivo       NUMBER                    := 10;
      /*vsfacult       cuafacul.sfacult%TYPE; 19484 AVT 02/01/2012*/
      vsfacult      VARCHAR2 (100);
      v_cmotmov     NUMBER;
      mens          VARCHAR2 (2000);
      v_funcion     VARCHAR2 (100);
      ss            VARCHAR2 (2000);
      pfini         DATE;

      /* 19484 AVT 02/01/2012*/
      /* 21051 AVT 31/01/2012 anirem a les taules reals*/
      CURSOR facultatiu (c_seg IN NUMBER)
      IS
         SELECT sfacult
           FROM cuafacul
          WHERE sseguro = c_seg AND cestado = 1;

      -- INI - 4820 - ML - VUELVO A HABILITAR CONSULTA ANTERIOR, YA QUE EL ESTADO 2 ES PARA FACULTATIVOS COMPLETADOS

      /* 21051 AVT 31/01/2012 anirem a les taules reals*/
     /* 21051 AVT 31/01/2012 anirem a les taules reals*/
/*Se modifica el cursor rea_facultatiu  tarea IAXIS-4503  sobre cuadro facultativo en aumento de amparo 01/07/2019
       1. se cambia el estado a 2 para que se pueda crear un nuevo facultativo cuando se realiza un suplemento
       2. el estado  se cambia a 2 ya que cuando se crea un facultativo y se edita el estado de terminado es 2 pero anteriormente
          estaba en 1 entonces el cursor no llamaba a ningun cuadro facultativo.
           Consulta antes del cambio

          SELECT sfacult
           FROM cuafacul
          WHERE scumulo IN (SELECT scumulo
                              FROM reariesgos
                             WHERE sseguro = c_seg) AND cestado = 1;
        SELECT sfacult
           FROM cuafacul
          WHERE sseguro = c_seg  AND cestado = 2 and rownum = 1 order by nmovimi desc ;
      */
      CURSOR rea_facultatiu (c_seg IN NUMBER)
      IS
         SELECT sfacult
           FROM cuafacul
          WHERE scumulo IN (SELECT scumulo
                              FROM reariesgos
                             WHERE sseguro = c_seg) AND cestado = 1;
   -- FIN - 4820 - ML - VUELVO A HABILITAR CONSULTA ANTERIOR, YA QUE EL ESTADO 2 ES PARA FACULTATIVOS COMPLETADOS
   BEGIN
      /* JLB - I - BUG 18423 COjo la moneda del producto*/
      /*   v_moneda := f_parinstalacion_n('MONEDAINST');*/
      /* JLB - f - BUG 18423 COjo la moneda del producto*/
      vpasexec := 5001;
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_MD_PRODUCCION',
                       'CREA_FACUL',
                       NULL,
                       2,
                       'Error: paso 1 '
                      );

      /*?Cuadro Facultativo xxx generado correctamente. Una vez completo el Cuadro cualquier cambio en los capitales de la propuesta supondr?una nueva retenci??e la p??a.?*/
      IF psseguro IS NULL OR pnmovimi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         SELECT sproduc, cempres
           INTO vsproduc, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_md_produccion.f_crear_facul',
                         vpasexec,
                         'select seguros psseguro:' || psseguro || ')',
                         SQLERRM
                        );
      END;

      /* JLB - I - BUG 18423 COjo la moneda del producto*/
      v_moneda := pac_monedas.f_moneda_producto (vsproduc);
      /* JLB - f - BUG 18423 COjo la moneda del producto*/
      vpasexec := 2;
      vnumerr := pac_seguros.f_get_csituac (psseguro, 'POL', v_csituac);

      IF vnumerr <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_md_produccion.f_crear_facul',
                      vpasexec,
                      ' pac_seguros.f_get_csituac:' || psseguro || ')',
                      SQLERRM
                     );
      END IF;

      vpasexec := 3;
      onmovimi := pnmovimi;

      /*21559 26/03/2012 AVT detectat error al crear facultatius en els suplements*/
      /*30702 01/04/2014 KBR renovación de cartera (Propuesta de cartera)*/
      IF v_csituac IN (5, 17)
      THEN
         vpasexec := 4;
         /* 21051 AVT 31/01/2012 anirem a les taules reals*/
         /*      BEGIN*/
         /*         SELECT m.fefecto, m.cmotmov*/
         /*           INTO v_fefesup, v_cmotmov*/
         /*           FROM movseguro m*/
         /*          WHERE m.sseguro = psseguro*/
         /*            AND m.nmovimi = (SELECT MAX(m1.nmovimi)*/
         /*                               FROM movseguro m1*/
         /*                              WHERE m1.sseguro = m.sseguro);*/
         /*      EXCEPTION*/
         /*         WHEN OTHERS THEN*/
         /*            p_tab_error(f_sysdate, f_user, 'pac_md_produccion.f_crear_facul', vpasexec,*/
         /*                        ' select movseguro:' || psseguro || ')', SQLERRM);*/
         /*      END;*/
         vpasexec := 5;
         /* 21051 AVT 31/01/2012 anirem a les taules reals*/
         /*      vnumerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'MODIF_PROP', v_fefesup,*/
         /*                                                         'BBDD', '*', NULL, oestsseguro,*/
         /*                                                         onmovimi);*/
         vpasexec := 6;

         /*BUG 19484 - 19/10/2011 - JRB - Se a??n las funciones est para el reaseguro.*/
         IF     NVL (pac_parametros.f_parempresa_n (v_cempres,
                                                    'REASEGURO_EST'),
                     0
                    ) = 1
            AND pac_cesionesrea.producte_reassegurable (vsproduc) = 1
         THEN
            vpasexec := 7;

            IF vsproces IS NULL
            THEN
               lsproces := 111313;
            ELSE
               lsproces := vsproces;
            END IF;

            vpasexec := 8;
            vnumerr :=
               pac_cesionesrea.f_buscactrrea_est (psseguro,
                                                  onmovimi,
                                                  lsproces,
                                                  4,
                                                  v_moneda,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  'REA'
                                                 );

            /* 21051 AVT 31/01/2012 anirem a les taules reals*/
            IF vnumerr <> 0 AND vnumerr <> 99
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_md_produccion.f_crear_facul',
                            vpasexec,
                            ' f_buscactrrea_est:' || psseguro || ')',
                            SQLERRM
                           );
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     vnumerr,
                                                     vterror
                                                    );
               vcreteni := 1;
            ELSIF vnumerr = 0
            THEN
               vpasexec := 9;
               /*Crea el cuadro*/
               vnumerr :=
                  pac_cesionesrea.f_cessio_est (lsproces,
                                                4,
                                                v_moneda,
                                                f_sysdate,
                                                1,
                                                'REA'
                                               );

               IF vnumerr <> 0 AND vnumerr <> 99
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_md_produccion.f_crear_facul',
                               vpasexec,
                               ' f_cessio_est:' || psseguro || ')',
                               SQLERRM
                              );
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                        1,
                                                        vnumerr,
                                                        vterror
                                                       );
                  vcreteni := 1;
               ELSIF vnumerr = 99 OR vnumerr = 0
               THEN
                  COMMIT;
                  vpasexec := 17;

                  /* AVT 07/12/2011 Q.FAC A NIVELL DE CUMUL!!! ------------------------------*/
                  /* 19484 AVT 02/01/2012 es canvia la select per un cursor per quan s'ha generat más d'un quadre*/
                  /* 21051 AVT 31/01/2012 anirem a les taules reals*/
                  FOR fac IN facultatiu (psseguro)
                  LOOP
                     vsfacult := fac.sfacult || ' ' || vsfacult;
                  END LOOP;

                  /* 21051 AVT 31/01/2012 anirem a les taules reals*/
                  FOR fac_rea IN rea_facultatiu (psseguro)
                  LOOP
                     vsfacult := fac_rea.sfacult || ' ' || vsfacult;
                  END LOOP;

                  /*BUG 28479/156418 - RCL - La póliza no requiere ningún cuadro facultativo.*/
                  IF vsfacult IS NOT NULL
                  THEN
                     /* 19484 AVT 02/01/2012 fi ----------------------------------------------------*/
                     vterror :=
                        f_axis_literales (9902568,
                                          pac_md_common.f_get_cxtidioma
                                         );
                     vterror := REPLACE (vterror, '#1#', vsfacult);
                     /*pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr, vterror);*/
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           2,
                                                           vnumerr,
                                                           vterror
                                                          );
--Bug 33116-189842 KJSC Cambiar missatge d'error per informatiu en la generació dels Quadres Facutatius
                  /*> Por facultativo*/
                  ELSE
                     /*BUG 28479/156418 - RCL - La póliza no requiere ningún cuadro facultativo.*/
                     vterror :=
                        f_axis_literales (9906179,
                                          pac_md_common.f_get_cxtidioma
                                         );
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           2,
                                                           vnumerr,
                                                           vterror
                                                          );
                  END IF;

                  vcreteni := 0;
               END IF;
            END IF;

            vpasexec := 10;
         END IF;
      ELSE
         vpasexec := 11;
         p_traza_proceso (24,
                          'TRAZA_CESIONES_REA',
                          777,
                          'PAC_MD_PRODUCCION',
                          'CREA_FACUL',
                          NULL,
                          2,
                          'Error: paso 2 '
                         );

         /* 21051 AVT 31/01/2012 anirem a les taules reals*/
         /*      vnumerr := pk_nueva_produccion.f_inicializar_modificacion(psseguro, oestsseguro,*/
         /*                                                                onmovimi);*/
         /*BUG 19484 - 19/10/2011 - JRB - Se a??n las funciones est para el reaseguro.*/
         IF     NVL (pac_parametros.f_parempresa_n (v_cempres,
                                                    'REASEGURO_EST'),
                     0
                    ) = 1
            AND pac_cesionesrea.producte_reassegurable (vsproduc) = 1
         THEN
            p_traza_proceso (24,
                             'TRAZA_CESIONES_REA',
                             777,
                             'PAC_MD_PRODUCCION',
                             'CREA_FACUL',
                             NULL,
                             2,
                             'Error: paso 3 '
                            );
            vpasexec := 12;

            IF vsproces IS NULL
            THEN
               lsproces := 111313;
            ELSE
               lsproces := vsproces;
            END IF;

            IF vnumerr = 0
            THEN
               SELECT pac_parametros.f_parproducto_t (vsproduc,
                                                      'F_PRE_EFE_REA'
                                                     )
                 INTO v_funcion
                 FROM DUAL;

               IF v_funcion IS NOT NULL
               THEN
                  ss :=
                        'begin :num_err := '
                     || v_funcion
                     || '(:lsproces, :psseguro, :v_nmovimi, :pfini); end;';

                  EXECUTE IMMEDIATE ss
                              USING OUT    vnumerr,
                                    IN     lsproces,
                                    IN     psseguro,
                                    IN     onmovimi,
                                    OUT    pfini;

                  IF vnumerr <> 0
                  THEN
                     vnumerr := 1;
                     ROLLBACK;
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'p_emitir_propuesta.f_pre_efe_rea',
                                  10,
                                     'lsproces: '
                                  || lsproces
                                  || 'psseguro: '
                                  || psseguro
                                  || 'v_nmovimi: '
                                  || onmovimi,
                                  vnumerr
                                 );
                  END IF;
               END IF;
            END IF;

            IF vnumerr = 0
            THEN
               vpasexec := 13;
               p_traza_proceso (24,
                                'TRAZA_CESIONES_REA',
                                777,
                                'PAC_MD_PRODUCCION',
                                'CREA_FACUL',
                                NULL,
                                2,
                                'Error: paso 4 '
                               );
               /* 21051 AVT 31/01/2012 anirem a les taules reals*/
               vnumerr :=
                  pac_cesionesrea.f_buscactrrea_est (psseguro,
                                                     1,
                                                     lsproces,
                                                     3,
                                                     v_moneda,
                                                     NULL,
                                                     pfini,
                                                     NULL,
                                                     'REA'
                                                    );
               p_traza_proceso (24,
                                'TRAZA_CESIONES_REA',
                                777,
                                'PAC_MD_PRODUCCION',
                                'CREA_FACUL',
                                NULL,
                                2,
                                'Error: paso 5, vnumerr: ' || vnumerr
                               );
            END IF;

            IF vnumerr <> 0 AND vnumerr <> 99
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     vnumerr,
                                                     vterror
                                                    );
               vcreteni := 1;
            ELSIF vnumerr = 0
            THEN
               vpasexec := 14;
               /*Crea el cuadro*/
               vnumerr :=
                  pac_cesionesrea.f_cessio_est (lsproces,
                                                3,
                                                v_moneda,
                                                f_sysdate,
                                                1,
                                                'REA'
                                               );

               IF vnumerr <> 0 AND vnumerr <> 99
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                        1,
                                                        vnumerr,
                                                        vterror
                                                       );
                  vcreteni := 1;
               ELSIF vnumerr = 99 OR vnumerr = 0
               THEN
                  COMMIT;
                  vpasexec := 18;

                  /* AVT 07/12/2011 Q.FAC A NIVELL DE CUMUL!!! ------------------------------*/
                  /* 19484 AVT 02/01/2012 es canvia la select per un cursor per quan s'ha generat más d'un quadre*/
                  /* 21051 AVT 31/01/2012 anirem a les taules reals*/
                  FOR fac IN facultatiu (psseguro)
                  LOOP
                     vsfacult := fac.sfacult || ' ' || vsfacult;
                  END LOOP;

                  /* 21051 AVT 31/01/2012 anirem a les taules reals*/
                  FOR fac_rea IN rea_facultatiu (psseguro)
                  LOOP
                     /* AVT 07/12/2011 Q.FAC A NIVELL DE CUMUL!!! FI ------------------------------*/
                     vsfacult := fac_rea.sfacult || ' ' || vsfacult;
                  END LOOP;

                  /*BUG 28479/156418 - RCL - La póliza no requiere ningún cuadro facultativo.*/
                  IF vsfacult IS NOT NULL
                  THEN
                     /* 19484 AVT 02/01/2012 fi ----------------------------------------------------*/
                     vterror :=
                        f_axis_literales (9902568,
                                          pac_md_common.f_get_cxtidioma
                                         );
                     vterror := REPLACE (vterror, '#1#', vsfacult);
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           vnumerr,
                                                           vterror
                                                          );
                  /*> Por facultativo*/
                  ELSE
                     /*BUG 28479/156418 - RCL - La póliza no requiere ningún cuadro facultativo.*/
                     vterror :=
                        f_axis_literales (9906179,
                                          pac_md_common.f_get_cxtidioma
                                         );
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           2,
                                                           vnumerr,
                                                           vterror
                                                          );
                  END IF;

                  vcreteni := 0;
               END IF;
            END IF;

            vpasexec := 15;
         END IF;
      END IF;

      vpasexec := 16;
      /* 21051 AVT 31/01/2012 anirem a les taules reals*/
      /*pac_alctr126.borrar_tablas_est(oestsseguro);*/
      RETURN 1;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_md_produccion.f_crear_facul',
                      vpasexec,
                      'error general',
                      SQLERRM
                     );
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_crear_facul;                       /*Bug.: 19152 - ICV - 25/10/2011*/

   /*Ini Bug.: 19152*/
   /*************************************************************************
      Función que inicializa el objeto de BENEIDENTIFICADOS riesgo
      param in pnriesgo  : número de riesgo
      param in psperson  : Código de personas
      param out mensajes : mensajes de error
      return             : number
      2.0    05/04/2019    CES      IAXIS-2132: Ajuste para la creacion de beneficiarios por defecto que sean los asegurados.
      2.1    18/06/2019             IAXIS-4320 Errores Ramo Cumplimiento
   *************************************************************************/
   FUNCTION f_insert_beneident_r (
      benef      IN       ob_iax_benespeciales,
      psperson   IN       NUMBER,
      pfefecto   IN       DATE,
      psseguro   IN       NUMBER,
      pnorden    OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_beneidentificados
   IS
      vpasexec      NUMBER (8)              := 1;
      vparam        VARCHAR2 (1000)
                   := 'pfefecto : ' || pfefecto || ' psperson : ' || psperson;
      vobject       VARCHAR2 (200)
                                  := 'PAC_MD_PRODUCCION.f_insert_beneident_r';
      num_err       NUMBER                  := 0;
      v_norden      NUMBER                  := 0;
      ob_benef      ob_iax_benespeciales    := ob_iax_benespeciales ();
      v_agenvisio   NUMBER;
      /* Cambios de 4545 : start */
      v_ramo        estseguros.cramo%TYPE;
      /* Cambios de 4545 : end */
      v_sperson     NUMBER;                     -- IAXIS-4203 CJMR 06/09/2019
   BEGIN
      IF pfefecto IS NULL OR psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ob_benef := benef;
      vpasexec := 2;

      IF ob_benef.benef_riesgo IS NOT NULL AND ob_benef.benef_riesgo.COUNT > 0
      THEN
           /*JRH 10/2011 IS NOT NULL*/
         -- INI-IAXIS-2132 CES 05/04/2019
         FOR i IN ob_benef.benef_riesgo.FIRST .. ob_benef.benef_riesgo.LAST
         LOOP
            vpasexec := 5;
            p_tab_error (f_sysdate,
                         f_user,
                         'PAC_MD_PRODUCCION.f_insert_beneident_r',
                         '1',
                         '1',
                            'vpasexec = '
                         || vpasexec
                         || ' VALOR DEL OBJETO :: '
                         || ob_benef.benef_riesgo (i).sperson
                         || ' VALOR DEL PARAMETRO ::'
                         || psperson
                         || ' - '
                         || SQLCODE
                         || ' - '
                         || SQLERRM
                        );

            -- INI IAXIS-4203 CJMR 06/09/2019
            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM per_personas
                WHERE sperson = ob_benef.benef_riesgo (i).sperson;
            EXCEPTION
               WHEN OTHERS
               THEN
                  BEGIN
                     SELECT spereal
                       INTO v_sperson
                       FROM estper_personas
                      WHERE sperson = ob_benef.benef_riesgo (i).sperson;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_sperson := 0;
                  END;
            END;

            --IF ob_benef.benef_riesgo (i).sperson = psperson
            -- FIN IAXIS-4203 CJMR 06/09/2019
            IF v_sperson = psperson
            THEN
               RETURN ob_benef.benef_riesgo;
            END IF;
         END LOOP;

         -- END-IAXIS-2132 CES 05/04/2019
         v_norden := ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).norden;
      ELSE
         ob_benef.benef_riesgo := t_iax_beneidentificados ();
      /*JRH IMP 10/2011*/
      END IF;

      vpasexec := 3;
      ob_benef.benef_riesgo.EXTEND;
      ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST) :=
                                                   ob_iax_beneidentificados
                                                                           ();
      vpasexec := 4;
      ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).sperson := psperson;
      vpasexec := 5;
      ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).finiben := pfefecto;
      ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).norden :=
                                                                  v_norden + 1;

      BEGIN
         --
         BEGIN
            SELECT cagente
              INTO v_agenvisio
              FROM estseguros ss
             WHERE ss.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_agenvisio := ff_agenteprod;
         END;

         --
         SELECT ff_desvalorfijo (672,
                                 pac_md_common.f_get_cxtidioma (),
                                 ctipide
                                ),
                nnumide,
                ed.tapelli1 || ' ' || ed.tapelli2 || ', ' || ed.tnombre
           INTO ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).ttipide,
                ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).nnumide,
                ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).nombre_ben
           FROM estper_personas ep, estper_detper ed
          WHERE ep.sperson = psperson
            AND ep.sperson = ed.sperson
            AND ed.cagente = ff_agente_cpervisio (v_agenvisio);
      EXCEPTION
         WHEN OTHERS
         THEN
            --INI IAXIS-4203 CJMR 26/06/2019
            BEGIN
               --
               SELECT ff_desvalorfijo (672,
                                       pac_md_common.f_get_cxtidioma (),
                                       ctipide
                                      ),
                      nnumide,
                      ed.tapelli1 || ' ' || ed.tapelli2 || ', ' || ed.tnombre
                 INTO ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).ttipide,
                      ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).nnumide,
                      ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).nombre_ben
                 FROM per_personas ep, per_detper ed
                WHERE ep.sperson = psperson AND ep.sperson = ed.sperson;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).ttipide :=
                                                                         '**';
                  ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).nnumide :=
                                                                         '**';
                  ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).nombre_ben :=
                                                                         '**';
            END;
      --FIN IAXIS-4203 CJMR 26/06/2019
      END;

      -- INI 5281 CJMR 17/09/2019
      IF NVL
            (pac_parametros.f_parproducto_n
                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                 'BENIDENT_RIES'
                                ),
             0
            ) = psperson
      THEN
         ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).cheredado := 1;
      ELSE
         /* Bug 30365/175325 - 03/06/2014 - AMC*/
         ob_benef.benef_riesgo (ob_benef.benef_riesgo.LAST).cheredado := 0;
      END IF;

      -- FIN 5281 CJMR 17/09/2019
      vpasexec := 6;
      pnorden := v_norden + 1;
      vpasexec := 7;

      /*added  FOR IAXIS 4545 restricted for COMPLIMENTO*/
      BEGIN
         SELECT DISTINCT cramo
                    INTO v_ramo
                    FROM estseguros
                   WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_ramo := NULL;
      END;

      vpasexec := 8;

      IF v_ramo = 801
      THEN
         IF ob_benef.benef_riesgo.COUNT > 1
/*Added for 4746 Error Endorsement change of Insured in Compliance, is not changing including / modifying the Beneficiary */
         THEN
            ob_benef.benef_riesgo.DELETE (1);
/*added for IAXIS-4320 Errores Ramo Cumplimiento for showing insured name during supplemento*/
         END IF;
      END IF;

      /*ENDED  FOR IAXIS 4545 restricted for COMPLIMENTO by rohit*/
      RETURN ob_benef.benef_riesgo;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_insert_beneident_r;

   /*************************************************************************
      Función que para actualizar el objeto OB_IAX_BENEIDENTIFICADOS riesgo
      param in pnriesgo  : número de riesgo
      param in pnorden  : orden dentro del objeto
      param in psperson_tit :
      param in pctipben :
      param in pcparen:
      param in ppparticip :
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_set_beneident_r (
      benef          IN       ob_iax_benespeciales,
      pnorden        IN       NUMBER,
      psperson_tit   IN       NUMBER,
      pctipben       IN       NUMBER,
      pcparen        IN       NUMBER,
      ppparticip     IN       NUMBER,
      pcestado       IN       NUMBER,
      /* Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado*/
      pctipcon       IN       NUMBER, /* Bug 34866/206821 - JAL - 10/06/2015*/
      psseguro       IN       NUMBER,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN t_iax_beneidentificados
   IS
      vpasexec      NUMBER (8)           := 1;
      vparam        VARCHAR2 (1000)
         :=    ' pnorden : '
            || pnorden
            || ' psperson_tit : '
            || psperson_tit
            || ' pctipben : '
            || pctipben
            || ' pcparen : '
            || pcparen
            || ' ppparticip : '
            || ppparticip
            || ' pcestado : '
            || pcestado;
      vobject       VARCHAR2 (200)    := 'PAC_MD_PRODUCCION.f_set_beneident_r';
      num_err       NUMBER               := 0;
      ob_benef      ob_iax_benespeciales := ob_iax_benespeciales ();
      v_agenvisio   NUMBER;
   BEGIN
      IF pnorden IS NULL OR pctipben IS NULL OR ppparticip IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ob_benef := benef;

      /*Recuperamos el ob_iax_beneidentificados deaseado*/
      IF ob_benef IS NOT NULL
      THEN
         vpasexec := 4;

         IF ob_benef.benef_riesgo.COUNT > 0
         THEN
            FOR i IN
               ob_benef.benef_riesgo.FIRST .. ob_benef.benef_riesgo.LAST
            LOOP
               vpasexec := 5;

               IF ob_benef.benef_riesgo.EXISTS (i)
               THEN
                  vpasexec := 6;

                  IF ob_benef.benef_riesgo (i).norden = pnorden
                  THEN
                     ob_benef.benef_riesgo (i).sperson_tit := psperson_tit;
                     ob_benef.benef_riesgo (i).ctipben := pctipben;
                     ob_benef.benef_riesgo (i).cparen := pcparen;
                     ob_benef.benef_riesgo (i).pparticip := ppparticip;
                     /* Ini Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado*/
                     ob_benef.benef_riesgo (i).cestado := pcestado;
                     ob_benef.benef_riesgo (i).ctipocon := pctipcon;
                     ob_benef.benef_riesgo (i).ttipocon :=
                        ff_desvalorfijo (8001024,
                                         pac_md_common.f_get_cxtidioma (),
                                         pctipcon
                                        );                   /* 34866/209952*/

                     IF pcestado IS NOT NULL
                     THEN
                        ob_benef.benef_riesgo (i).testado :=
                           ff_desvalorfijo (800128,
                                            pac_md_common.f_get_cxtidioma (),
                                            pcestado
                                           );
                     END IF;

                     /* Fin Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado*/
                     IF ob_benef.benef_riesgo (i).ctipben IS NOT NULL
                     THEN
                        /* Bug 24717 - MDS - 20/12/2012 : diferenciar la lista de valores especÃ­fica 800127 de la genárica 1053*/
                        IF pac_mdpar_productos.f_get_parproducto
                                ('ALTERNATIVO_BENEF',
                                 pac_iax_produccion.poliza.det_poliza.sproduc
                                ) = 1
                        THEN
                           ob_benef.benef_riesgo (i).ttipben :=
                              ff_desvalorfijo
                                           (800127,
                                            pac_md_common.f_get_cxtidioma (),
                                            pctipben
                                           );
                        ELSE
                           ob_benef.benef_riesgo (i).ttipben :=
                              ff_desvalorfijo
                                           (1053,
                                            pac_md_common.f_get_cxtidioma (),
                                            pctipben
                                           );
                        END IF;
                     /* Fin Bug 24717 - MDS - 20/12/2012*/
                     END IF;

                     IF ob_benef.benef_riesgo (i).cparen IS NOT NULL
                     THEN
                        ob_benef.benef_riesgo (i).tparen :=
                           ff_desvalorfijo (1054,
                                            pac_md_common.f_get_cxtidioma (),
                                            pcparen
                                           );
                     END IF;

                     BEGIN
                        SELECT cagente
                          INTO v_agenvisio
                          FROM estseguros ss
                         WHERE ss.sseguro = psseguro;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_agenvisio := ff_agenteprod;
                     END;

                     IF ob_benef.benef_riesgo (i).sperson_tit IS NOT NULL
                     THEN
                        BEGIN
                           SELECT    ed.tapelli1
                                  || ' '
                                  || ed.tapelli2
                                  || ', '
                                  || ed.tnombre
                             INTO ob_benef.benef_riesgo (i).nombre_tit
                             FROM estper_personas ep, estper_detper ed
                            WHERE ep.sperson = psperson_tit
                              AND ep.sperson = ed.sperson
                              AND ed.cagente =
                                             ff_agente_cpervisio (v_agenvisio);
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              ob_benef.benef_riesgo (i).nombre_tit := '';
                              ob_benef.benef_riesgo (i).sperson_tit := 0;
                        END;
                     /* ob_benef.benef_riesgo(i).nombre_tit := f_nombre(psperson_tit,1,pac_md_common.f_get_cxtagente());*/
                     ELSE
                        ob_benef.benef_riesgo (i).nombre_tit := '';
                        ob_benef.benef_riesgo (i).sperson_tit := 0;
                     END IF;

                     /*ACTUALIZAMOS DATOS DEl objeto por si hemos cambiado la persona.*/
                     BEGIN
                        SELECT ff_desvalorfijo
                                            (672,
                                             pac_md_common.f_get_cxtidioma (),
                                             ctipide
                                            ),
                               nnumide,
                                  ed.tapelli1
                               || ' '
                               || ed.tapelli2
                               || ', '
                               || ed.tnombre
                          INTO ob_benef.benef_riesgo (i).ttipide,
                               ob_benef.benef_riesgo (i).nnumide,
                               ob_benef.benef_riesgo (i).nombre_ben
                          FROM estper_personas ep, estper_detper ed
                         WHERE ep.sperson = ob_benef.benef_riesgo (i).sperson
                           AND ep.sperson = ed.sperson
                           AND ed.cagente = ff_agente_cpervisio (v_agenvisio);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           --INI IAXIS-4203 CJMR 26/06/2019
                           BEGIN
                              SELECT ff_desvalorfijo
                                            (672,
                                             pac_md_common.f_get_cxtidioma (),
                                             ctipide
                                            ),
                                     nnumide,
                                        ed.tapelli1
                                     || ' '
                                     || ed.tapelli2
                                     || ', '
                                     || ed.tnombre
                                INTO ob_benef.benef_riesgo (i).ttipide,
                                     ob_benef.benef_riesgo (i).nnumide,
                                     ob_benef.benef_riesgo (i).nombre_ben
                                FROM per_personas ep, per_detper ed
                               WHERE ep.sperson =
                                             ob_benef.benef_riesgo (i).sperson
                                 AND ep.sperson = ed.sperson;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 ob_benef.benef_riesgo (i).ttipide := '**';
                                 ob_benef.benef_riesgo (i).nnumide := '**';
                                 ob_benef.benef_riesgo (i).nombre_ben := '**';
                           END;
                     --FIN IAXIS-4203 CJMR 26/06/2019
                     END;

                     -- INI 5281 CJMR 17/09/2019
                     IF NVL
                           (pac_parametros.f_parproducto_n
                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                 'BENIDENT_RIES'
                                ),
                            0
                           ) = psperson_tit
                     THEN
                        ob_benef.benef_riesgo (i).cheredado := 1;
                     ELSE
                        /* Bug 30365/175325 - 03/06/2014 - AMC*/
                        ob_benef.benef_riesgo (i).cheredado := 0;
                     END IF;
                  -- FIN 5281 CJMR 17/09/2019
                  END IF;
               END IF;
            END LOOP;

            vpasexec := 7;
         END IF;
      END IF;

      vpasexec := 8;
      RETURN ob_benef.benef_riesgo;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_set_beneident_r;

   /*************************************************************************
     Función que inicializa el objeto de OB_iax_benespeciales_gar
     param in pnriesgo  : número de riesgo
     param in pcgarant  : Código de garantÃ­a
     param out mensajes : mensajes de error
     return             : number
   *************************************************************************/
   FUNCTION f_insert_benesp_gar (
      benef      IN       ob_iax_benespeciales,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_benespeciales_gar
   IS
      vpasexec   NUMBER (8)           := 1;
      vparam     VARCHAR2 (1000)      := ' pcgarant : ' || pcgarant;
      vobject    VARCHAR2 (200)    := 'PAC_MD_PRODUCCION.f_insert_benesp_gar';
      num_err    NUMBER               := 0;
      rie        ob_iax_riesgos;
      v_norden   NUMBER               := 0;
      ob_benef   ob_iax_benespeciales := ob_iax_benespeciales ();
   BEGIN
      IF pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ob_benef := benef;
      vpasexec := 3;

      IF ob_benef IS NULL
      THEN
         ob_benef := ob_iax_benespeciales ();
      END IF;

      IF ob_benef.benefesp_gar IS NULL
      THEN
         ob_benef.benefesp_gar := t_iax_benespeciales_gar ();
      END IF;

      /*  if ob_benef.benefesp_gar is null then
      ob_benef.benfesp_gar */
      IF ob_benef.benefesp_gar IS NOT NULL
      THEN
         IF ob_benef.benefesp_gar.COUNT > 0
         THEN
            vpasexec := 5;

            /*Revisamos que no estemos intentando dar de alta la misma garantÃ­a 2 veces*/
            FOR i IN
               ob_benef.benefesp_gar.FIRST .. ob_benef.benefesp_gar.LAST
            LOOP
               IF ob_benef.benefesp_gar.EXISTS (i)
               THEN
                  vpasexec := 6;

                  IF ob_benef.benefesp_gar (i).cgarant = pcgarant
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           9902559
                                                          );
                     RAISE e_object_error;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF ob_benef.benefesp_gar.COUNT = 0 OR ob_benef.benefesp_gar IS NULL
      THEN
         ob_benef.benefesp_gar := t_iax_benespeciales_gar ();
      END IF;

      ob_benef.benefesp_gar.EXTEND;
      ob_benef.benefesp_gar (ob_benef.benefesp_gar.LAST) :=
                                                   ob_iax_benespeciales_gar
                                                                           ();
      ob_benef.benefesp_gar (ob_benef.benefesp_gar.LAST).cgarant := pcgarant;

      BEGIN
         SELECT tgarant
           INTO ob_benef.benefesp_gar (ob_benef.benefesp_gar.LAST).tgarant
           FROM garangen g
          WHERE g.cgarant = pcgarant
            AND g.cidioma = pac_md_common.f_get_cxtidioma ();
      EXCEPTION
         WHEN OTHERS
         THEN
            ob_benef.benefesp_gar (ob_benef.benefesp_gar.LAST).tgarant :=
                                                                         '**';
      END;

      vpasexec := 5;
      RETURN ob_benef.benefesp_gar;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_insert_benesp_gar;

   /*************************************************************************
      Función que inicializa el objeto de OB_iax_beneidentificados GarantÃ­a
      param in pnriesgo  : número de riesgo
      param in pcgarant  : Código de garantÃ­a
      param in psperson  : Código de persona
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_insert_beneident_g (
      benef      IN       ob_iax_benespeciales,
      pfefecto   IN       DATE,
      pcgarant   IN       NUMBER,
      psperson   IN       NUMBER,
      psseguro   IN       NUMBER,
      pnorden    OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_benespeciales_gar
   IS
      vpasexec      NUMBER (8)           := 1;
      vparam        VARCHAR2 (1000)
         :=    'pfefecto : '
            || pfefecto
            || ' psperson : '
            || psperson
            || ' pcgarant : '
            || pcgarant;
      vobject       VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_insert_beneident_g';
      num_err       NUMBER               := 0;
      v_norden      NUMBER               := 0;
      ob_benef      ob_iax_benespeciales := ob_iax_benespeciales ();
      v_agenvisio   NUMBER;
   BEGIN
      IF pfefecto IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ob_benef := benef;

      /*Buscamos la colección por garantÃ­a*/
      IF ob_benef.benefesp_gar IS NULL
      THEN
         RETURN NULL;
      END IF;

      IF ob_benef.benefesp_gar.COUNT > 0
      THEN
         vpasexec := 5;

         FOR i IN ob_benef.benefesp_gar.FIRST .. ob_benef.benefesp_gar.LAST
         LOOP
            IF ob_benef.benefesp_gar.EXISTS (i)
            THEN
               vpasexec := 6;

               IF ob_benef.benefesp_gar (i).cgarant = pcgarant
               THEN
                  /*Inicializamos el objeto de beneficiarios especiales*/
                  vpasexec := 7;
                  vpasexec := 8;

                  IF ob_benef.benefesp_gar (i).benef_ident IS NULL
                  THEN
                     ob_benef.benefesp_gar (i).benef_ident :=
                                                   t_iax_beneidentificados
                                                                          ();
                  END IF;

                  IF ob_benef.benefesp_gar (i).benef_ident.COUNT > 0
                  THEN
                     v_norden :=
                        ob_benef.benefesp_gar (i).benef_ident
                                   (ob_benef.benefesp_gar (i).benef_ident.LAST
                                   ).norden;
                  END IF;

                  ob_benef.benefesp_gar (i).benef_ident.EXTEND;
                  ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ) := ob_iax_beneidentificados ();
                  ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).sperson := psperson;
                  ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).finiben := pfefecto;
                  vpasexec := 9;
                  ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).norden := v_norden + 1;

                  BEGIN
                     BEGIN
                        SELECT cagente
                          INTO v_agenvisio
                          FROM estseguros ss
                         WHERE ss.sseguro = psseguro;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_agenvisio := ff_agenteprod;
                     END;

                     --
                     SELECT ff_desvalorfijo (672,
                                             pac_md_common.f_get_cxtidioma (),
                                             ctipide
                                            ),
                            nnumide,
                               ed.tapelli1
                            || ' '
                            || ed.tapelli2
                            || ', '
                            || ed.tnombre
                       INTO ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).ttipide,
                            ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).nnumide,
                            ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).nombre_ben
                       FROM estper_personas ep, estper_detper ed
                      WHERE ep.sperson = psperson
                        AND ep.sperson = ed.sperson
                        AND ed.cagente = ff_agente_cpervisio (v_agenvisio);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        --INI IAXIS-4203 CJMR 26/06/2019
                        BEGIN
                           SELECT ff_desvalorfijo
                                            (672,
                                             pac_md_common.f_get_cxtidioma (),
                                             ctipide
                                            ),
                                  nnumide,
                                     ed.tapelli1
                                  || ' '
                                  || ed.tapelli2
                                  || ', '
                                  || ed.tnombre
                             INTO ob_benef.benefesp_gar (i).benef_ident
                                     (ob_benef.benefesp_gar (i).benef_ident.LAST
                                     ).ttipide,
                                  ob_benef.benefesp_gar (i).benef_ident
                                     (ob_benef.benefesp_gar (i).benef_ident.LAST
                                     ).nnumide,
                                  ob_benef.benefesp_gar (i).benef_ident
                                     (ob_benef.benefesp_gar (i).benef_ident.LAST
                                     ).nombre_ben
                             FROM estper_personas ep, estper_detper ed
                            WHERE ep.sperson = psperson
                              AND ep.sperson = ed.sperson;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              ob_benef.benefesp_gar (i).benef_ident
                                   (ob_benef.benefesp_gar (i).benef_ident.LAST
                                   ).ttipide := '**';
                              ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).nnumide := '**';
                              ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).nombre_ben := '**';
                        END;
                  --FIN IAXIS-4203 CJMR 26/06/2019
                  END;

                  /* ob_benef.benefesp_gar(i).benef_ident
                  (ob_benef.benefesp_gar(i).benef_ident.LAST).nombre_ben :=
                  f_nombre(psperson, 1,
                  pac_md_common.f_get_cxtagente());      */
                  /* Bug 30365/175325 - 03/06/2014 - AMC*/
                  ob_benef.benefesp_gar (i).benef_ident
                                    (ob_benef.benefesp_gar (i).benef_ident.LAST
                                    ).cheredado := 0;
               END IF;
            END IF;
         END LOOP;
      END IF;

      pnorden := v_norden + 1;
      vpasexec := 10;
      RETURN ob_benef.benefesp_gar;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_insert_beneident_g;

   /*************************************************************************
   Función que para actualizar el objeto OB_IAX_BENEIDENTIFICADOS garantÃ­a
   param in pnriesgo  : número de riesgo
   param in pnorden  : orden dentro del objeto
   param in psperson_tit :
   param in pctipben :
   param in pcparen:
   param in ppparticip :
   param in pcgarant
   param out mensajes : mensajes de error
   return             : number
   *************************************************************************/
   FUNCTION f_set_beneident_g (
      benef          IN       ob_iax_benespeciales,
      pnorden        IN       NUMBER,
      psperson_tit   IN       NUMBER,
      pctipben       IN       NUMBER,
      pcparen        IN       NUMBER,
      ppparticip     IN       NUMBER,
      pcgarant       IN       NUMBER,
      pcestado       IN       NUMBER,
      /* Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado*/
      pctipcon       IN       NUMBER,
      /* Bug 34866/206821 - JAL - 10/06/2015*/
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN t_iax_benespeciales_gar
   IS
      vpasexec   NUMBER (8)           := 1;
      vparam     VARCHAR2 (1000)
         :=    ' pnorden : '
            || pnorden
            || ' psperson_tit : '
            || psperson_tit
            || ' pctipben : '
            || pctipben
            || ' pcparen : '
            || pcparen
            || ' ppparticip : '
            || ppparticip
            || ' pcgarant : '
            || pcgarant
            || ' pcestado : '
            || pcestado;
      vobject    VARCHAR2 (200)       := 'PAC_MD_PRODUCCION.f_set_beneident_g';
      num_err    NUMBER               := 0;
      ob_benef   ob_iax_benespeciales := ob_iax_benespeciales ();
   BEGIN
      IF    pnorden IS NULL
         OR pctipben IS NULL
         OR ppparticip IS NULL
         OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ob_benef := benef;

      /*Recuperamos el ob_iax_beneidentificados deaseado*/
      IF ob_benef IS NOT NULL
      THEN
         vpasexec := 4;

         IF ob_benef.benefesp_gar.COUNT > 0
         THEN
            vpasexec := 5;

            /*Nos situamos en la garantÃ­a*/
            FOR j IN
               ob_benef.benefesp_gar.FIRST .. ob_benef.benefesp_gar.LAST
            LOOP
               IF ob_benef.benefesp_gar.EXISTS (j)
               THEN
                  vpasexec := 6;

                  IF ob_benef.benefesp_gar (j).cgarant = pcgarant
                  THEN
                     IF ob_benef.benefesp_gar (j).benef_ident.COUNT > 0
                     THEN
                        FOR i IN
                           ob_benef.benefesp_gar (j).benef_ident.FIRST .. ob_benef.benefesp_gar
                                                                            (j
                                                                            ).benef_ident.LAST
                        LOOP
                           vpasexec := 7;

                           IF ob_benef.benefesp_gar (j).benef_ident.EXISTS
                                                                          (i)
                           THEN
                              vpasexec := 8;

                              IF ob_benef.benefesp_gar (j).benef_ident (i).norden =
                                                                      pnorden
                              THEN
                                 ob_benef.benefesp_gar (j).benef_ident (i).sperson_tit :=
                                                                 psperson_tit;
                                 ob_benef.benefesp_gar (j).benef_ident (i).ctipben :=
                                                                     pctipben;
                                 ob_benef.benefesp_gar (j).benef_ident (i).cparen :=
                                                                      pcparen;
                                 ob_benef.benefesp_gar (j).benef_ident (i).pparticip :=
                                                                   ppparticip;
                                 /* Ini Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado*/
                                 ob_benef.benefesp_gar (j).benef_ident (i).cestado :=
                                                                     pcestado;

                                 IF pcestado IS NOT NULL
                                 THEN
                                    ob_benef.benefesp_gar (j).benef_ident (i).testado :=
                                       ff_desvalorfijo
                                           (800128,
                                            pac_md_common.f_get_cxtidioma (),
                                            pcestado
                                           );
                                 END IF;

                                 /* Fin Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado*/
                                 IF ob_benef.benefesp_gar (j).benef_ident (i).ctipben IS NOT NULL
                                 THEN
                                    /* Bug 24717 - MDS - 20/12/2012 : diferenciar la lista de valores especÃ­fica 800127 de la genárica 1053*/
                                    IF pac_mdpar_productos.f_get_parproducto
                                          ('ALTERNATIVO_BENEF',
                                           pac_iax_produccion.poliza.det_poliza.sproduc
                                          ) = 1
                                    THEN
                                       ob_benef.benefesp_gar (j).benef_ident
                                                                          (i).ttipben :=
                                          ff_desvalorfijo
                                             (800127,
                                              pac_md_common.f_get_cxtidioma
                                                                           (),
                                              pctipben
                                             );
                                    ELSE
                                       ob_benef.benefesp_gar (j).benef_ident
                                                                          (i).ttipben :=
                                          ff_desvalorfijo
                                             (1053,
                                              pac_md_common.f_get_cxtidioma
                                                                           (),
                                              pctipben
                                             );
                                    END IF;
                                 /* Fin Bug 24717 - MDS - 20/12/2012*/
                                 END IF;

                                 IF ob_benef.benefesp_gar (j).benef_ident (i).cparen IS NOT NULL
                                 THEN
                                    ob_benef.benefesp_gar (j).benef_ident (i).tparen :=
                                       ff_desvalorfijo
                                           (1054,
                                            pac_md_common.f_get_cxtidioma (),
                                            pcparen
                                           );
                                 END IF;

                                 IF ob_benef.benefesp_gar (j).benef_ident (i).sperson_tit IS NOT NULL
                                 THEN
                                    BEGIN
                                       SELECT    ed.tapelli1
                                              || ' '
                                              || ed.tapelli2
                                              || ', '
                                              || ed.tnombre
                                         INTO ob_benef.benefesp_gar (j).benef_ident
                                                                           (i).nombre_tit
                                         FROM estper_personas ep,
                                              estper_detper ed
                                        WHERE ep.sperson = psperson_tit
                                          AND ep.sperson = ed.sperson
                                          AND ed.cagente =
                                                 ff_agente_cpervisio
                                                    (pac_iax_common.f_get_cxtagente
                                                                           ()
                                                    );
                                    EXCEPTION
                                       WHEN OTHERS
                                       THEN
                                          ob_benef.benefesp_gar (j).benef_ident
                                                                          (i).nombre_tit :=
                                                                           '';
                                          ob_benef.benefesp_gar (j).benef_ident
                                                                          (i).sperson_tit :=
                                                                            0;
                                    END;
                                 /*ob_benef.benefesp_gar(j).benef_ident(i).nombre_tit := f_nombre(psperson_tit,1,pac_md_common.f_get_cxtagente());*/
                                 ELSE
                                    ob_benef.benefesp_gar (j).benef_ident (i).nombre_tit :=
                                                                           '';
                                    ob_benef.benefesp_gar (j).benef_ident (i).sperson_tit :=
                                                                            0;
                                 END IF;

                                 /* Bug 30365/175325 - 03/06/2014 - AMC*/
                                 ob_benef.benefesp_gar (j).benef_ident (i).cheredado :=
                                                                             0;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               END IF;
            END LOOP;

            vpasexec := 9;
         END IF;
      END IF;

      vpasexec := 10;
      RETURN ob_benef.benefesp_gar;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_set_beneident_g;

   /*************************************************************************
   Función que devuelve una lista de garantÃ­as seleccionadas para beneficiario
   param in psseguro  : número de seguro
   param out mensajes : mensajes de error
   return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_garantias_benidgar (
      psseguro   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000) := 'psseguro : ' || psseguro;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_PRODUCCION.F_GET_GARANTIAS_BENIDGAR';
      num_err    NUMBER          := 0;
      cur        sys_refcursor;
      squery     VARCHAR2 (4000);
   BEGIN
      squery :=
            'select gg.cgarant, tgarant
                from estgaranseg g, estseguros s, garangen gg
                where g.cgarant = gg.cgarant and g.sseguro = '
         || psseguro
         || ' and g.sseguro = s.sseguro and g.cobliga = 1 and gg.cidioma =  '
         || pac_md_common.f_get_cxtidioma
         || ' and nvl(pac_parametros.f_pargaranpro_n(s.sproduc,s.cactivi,g.cgarant,''BENIDENT_GAR''),0) = 1';
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_garantias_benidgar;

   /*************************************************************************
     Función que comprueba que la garantÃ­a este seleccionada en caso de beneficiario especial por garantÃ­a, si no lo está la borra
     param in psseguro  : número de seguro
     param out mensajes : mensajes de error
     return             : number
   *************************************************************************/
   FUNCTION f_comprobar_benidgar (
      psseguro       IN       NUMBER,
      pnriesgo       IN       NUMBER,
      pcgarant       IN       NUMBER,
      benefesp_gar   IN OUT   t_iax_benespeciales_gar,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
                  := ' psseguro : ' || psseguro || ' pnriesgo : ' || pnriesgo;
      vobject    VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.f_comprobar_benidgar';
      num_err    NUMBER          := 0;
      v_dummy    NUMBER;
   BEGIN
      IF psseguro IS NULL OR benefesp_gar IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*Recuperamos el ob_iax_beneidentificados deaseado*/
      IF benefesp_gar IS NOT NULL
      THEN
         vpasexec := 4;

         IF benefesp_gar.COUNT > 0
         THEN
            FOR i IN benefesp_gar.FIRST .. benefesp_gar.LAST
            LOOP
               vpasexec := 5;

               IF benefesp_gar.EXISTS (i)
               THEN
                  vpasexec := 6;

                  IF benefesp_gar (i).cgarant = pcgarant
                  THEN
                     /*Comprobamos que la garantÃ­a este marcada en las est como obligatoria, si no lo esta borramos*/
                     SELECT COUNT ('1')
                       INTO v_dummy
                       FROM estgaranseg eg
                      WHERE eg.sseguro = psseguro
                        AND eg.cgarant = pcgarant
                        AND eg.nriesgo = pnriesgo
                        AND eg.cobliga = 1;

                     IF v_dummy = 0
                     THEN
                        benefesp_gar.DELETE (i);
                     END IF;
                  END IF;
               END IF;
            END LOOP;

            vpasexec := 8;
         END IF;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_comprobar_benidgar;

   /* Ini bug 19303 - JMC - 21/11/2011*/
   /*************************************************************************
      FUNCTION f_crearpropuesta_sp
      Función que generara una póliza del producto SALDAR o PRORROGAR, tomando
      los datos de una póliza origen
      psseguro in number: código del seguro origen
      piprima_np in number:
      picapfall_np in number: capital fallecimiento de la nueva póliza
      pfvencim_np in date: fecha vencimiento de la nueva póliza
      pmode in number: Modo
      pfecha in date: fecha efecto nueva póliza.
      psolicit out number: Número solicitud.
      purl out varchar2:
      pmensa in out varchar2: mensajes de error.
      return number: retorno de la función f_crearpropuesta_sp
   *************************************************************************/
   FUNCTION f_crearpropuesta_sp (
      psseguro       IN       NUMBER,
      piprima_np     IN       NUMBER,
      picapfall_np   IN       NUMBER,
      pfvencim_np    IN       DATE,
      pmode          IN       VARCHAR2,
      pfecha         IN       DATE,
      pssolicit      OUT      NUMBER,
      purl           OUT      VARCHAR2,
      pmensa         IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1000)
         :=    ' psseguro : '
            || psseguro
            || ' piprima_np : '
            || piprima_np
            || ' picapfall_np : '
            || picapfall_np
            || ' pfvencim_np : '
            || pfvencim_np
            || ' pmode : '
            || pmode
            || ' pfecha : '
            || pfecha;
      vobject    VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.f_crearpropuesta_sp';
      num_err    NUMBER          := 0;
      vmensa     VARCHAR2 (2000);
      vfecha     DATE;
   BEGIN
      IF    psseguro IS NULL
         OR piprima_np IS NULL
         OR picapfall_np IS NULL
         /*OR pfvencim_np IS NULL*/
         OR pmode IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vfecha := pfecha - 1;
      num_err :=
         pk_nueva_produccion.f_crearpropuesta_sp (psseguro,
                                                  piprima_np,
                                                  picapfall_np,
                                                  pfvencim_np,
                                                  pmode,
                                                  vfecha,
                                                  pssolicit,
                                                  purl,
                                                  vmensa
                                                 );

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (pmensa, 1, num_err, vmensa);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (pmensa,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (pmensa,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (pmensa,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_crearpropuesta_sp;

   /* Fi bug 19303 - JMC - 21/11/2011*/
   /* ini BUG 0020761 - 03/01/2012 - JMF*/
   /***************************************************************************
      -- BUG 0020761 - 03/01/2012 - JMF
      Dado tipo cuenta nos dice si es tarjeta o no.
      param in  pctipban:  numero de la póliza.
      return: NUMBER (0=No, 1=Si).
   ***************************************************************************/
   FUNCTION f_get_tarjeta (pctipban IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      vparam      VARCHAR2 (200);
      vpasexec    NUMBER (8)     := 1;
      vobject     VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_get_tarjeta';
      v_tarjeta   NUMBER;
   BEGIN
      v_tarjeta := pac_ccc.f_estarjeta (NULL, pctipban);
      RETURN v_tarjeta;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_tarjeta;

   /* fin BUG 0020761 - 03/01/2012 - JMF*/
   /* BUG20498:DRA:09/01/2012:Inici*/
   FUNCTION f_grabapreguntasclausula (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      ptablas    IN       VARCHAR2,
      preg       IN OUT   t_iax_preguntas,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      /**/
      nerr       NUMBER          := 0;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (500)
         :=    'psseguro='
            || psseguro
            || ' pnmovimi='
            || pnmovimi
            || ' pfefecto='
            || pfefecto
            || ' ptablas='
            || ptablas;
      vobject    VARCHAR2 (200)
                               := 'PAC_MD_PRODUCCION.F_grabapreguntasclausula';
      vpsesion   NUMBER;
      vsproces   NUMBER;

      CURSOR c_seg
      IS
         SELECT cramo, cmodali, ctipseg, ccolect
           FROM seguros s
          WHERE s.sseguro = psseguro AND NVL (ptablas, 'POL') <> 'EST'
         UNION ALL
         SELECT cramo, cmodali, ctipseg, ccolect
           FROM estseguros s
          WHERE s.sseguro = psseguro AND NVL (ptablas, 'POL') = 'EST';

      r_seg      c_seg%ROWTYPE;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      /* Seleccionamos el número de sesión del proceso.*/
      SELECT sgt_sesiones.NEXTVAL
        INTO vpsesion
        FROM DUAL;

      vpasexec := 3;

      /* obtenemos el proceso*/
      SELECT starifa.NEXTVAL
        INTO vsproces
        FROM DUAL;

      vpasexec := 4;
      /*borramos la información que tenemos del riesgo.*/
      /* JLB - I- Optimización de tarificación*/
      /*  DELETE FROM sgt_parms_transitorios*/
      /*        WHERE sesion = vpsesion*/
      /*         AND parametro <> 'SESION';*/
      nerr := pac_sgt.del (vpsesion);

      IF nerr <> 0
      THEN
         RETURN 108438;
      END IF;

      nerr := pac_sgt.put (vpsesion, 'SESION', vpsesion);

      IF nerr <> 0
      THEN
         RETURN 108438;
      END IF;

      /* JLB - F - Optimizacióin*/
      vpasexec := 5;

      OPEN c_seg;

      FETCH c_seg
       INTO r_seg;

      CLOSE c_seg;

      vpasexec := 6;
      /*empezamos a trabajar con la nueva sesion*/
      nerr :=
         pac_tarifas.f_insertar_preguntas_clausulas (vpsesion,
                                                     vsproces,
                                                     ptablas,
                                                     psseguro,
                                                     0,
                                                     r_seg.cramo,
                                                     r_seg.cmodali,
                                                     r_seg.ctipseg,
                                                     r_seg.ccolect,
                                                     pnmovimi,
                                                     pfefecto,
                                                     'R'
                                                    );

      IF nerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;

      IF preg IS NULL
      THEN
         preg := t_iax_preguntas ();
      END IF;

      vpasexec := 8;

      FOR pr IN (SELECT cpregun, crespue, trespue, nmovimi
                   FROM pregunpolseg
                  WHERE sseguro = psseguro
                    AND nmovimi = pnmovimi
                    AND NVL (ptablas, 'POL') <> 'EST'
                 UNION ALL
                 SELECT cpregun, crespue, trespue, nmovimi
                   FROM estpregunpolseg
                  WHERE sseguro = psseguro
                    AND nmovimi = pnmovimi
                    AND NVL (ptablas, 'POL') = 'EST')
      LOOP
         preg.EXTEND;
         preg (preg.LAST) := ob_iax_preguntas ();
         preg (preg.LAST).cpregun := pr.cpregun;
         preg (preg.LAST).crespue := pr.crespue;
         preg (preg.LAST).trespue := pr.trespue;
         preg (preg.LAST).nmovimi := pr.nmovimi;
      END LOOP;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_grabapreguntasclausula;

   /* BUG20498:DRA:09/01/2012:Fi*/
   /*  Ini Bug 21907 - MDS - 23/04/2012*/
   /***********************************************************************
      Devuelve los valores de descuentos y recargos de un riesgo
      param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales)
      param in psseguro  : Numero interno de seguro
      param in pnriesgo  : Numero interno de riesgo
      param out pdtocom  : Porcentaje descuento comercial
      param out precarg  : Porcentaje recargo tácnico
      param out pdtotec  : Porcentaje descuento tácnico
      param out preccom  : Porcentaje recargo comercial
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_dtorec_riesgo (
      ptablas    IN       VARCHAR2 DEFAULT 'EST',
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pdtocom    OUT      NUMBER,
      precarg    OUT      NUMBER,
      pdtotec    OUT      NUMBER,
      preccom    OUT      NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         :=    'PTABLAS: '
            || ptablas
            || ', PSSEGURO: '
            || psseguro
            || ', PNRIESGO: '
            || pnriesgo;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.F_Get_DtoRec_Riesgo';
      num_err    NUMBER         := 0;
   BEGIN
      IF psseguro IS NULL OR pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err :=
         pac_calc_comu.f_get_dtorec_riesgo (NVL (ptablas, 'EST'),
                                            psseguro,
                                            pnriesgo,
                                            pdtocom,
                                            precarg,
                                            pdtotec,
                                            preccom
                                           );
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN -1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         ROLLBACK;
         RETURN -1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         ROLLBACK;
         RETURN -1;
   END f_get_dtorec_riesgo;

   /* 18/07/2012 - MDS - 0022824: LCOL_T010-Duplicado de propuestas*/
   FUNCTION f_dup_seguro (
      psseguroorig     IN       NUMBER,
      pfefecto         IN       DATE,
      pobservaciones   IN       VARCHAR2,
      pssegurodest     OUT      NUMBER,
      pnsolicidest     OUT      NUMBER,
      pnpolizadest     OUT      NUMBER,
      pncertifdest     OUT      NUMBER,
      ptipotablas      IN       NUMBER DEFAULT NULL,
      pcagente         IN       NUMBER DEFAULT NULL, --CONF-249-30/11/2016-RCS
      mensajes         IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (500)
         := 'psseguroorig: ' || psseguroorig || ', ptipotablas: '
            || ptipotablas;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_dup_seguro';
      num_err    NUMBER         := 0;
   BEGIN
      IF psseguroorig IS NULL OR pfefecto IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err :=
         pac_duplicar.f_dup_seguro (psseguroorig,
                                    pfefecto,
                                    pobservaciones,
                                    pssegurodest,
                                    pnsolicidest,
                                    pnpolizadest,
                                    pncertifdest,
                                    ptipotablas,
                                    pcagente
                                   );                --CONF-249-30/11/2016-RCS

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_dup_seguro;

   /***************************************************************************
      -- BUG 22839 - 24/07/2012 - RSC
      Indica si la garantÃ­a se encuentra contratada o no en el certificado 0.
      return: NUMBER (0=No, 1=Si).
   ***************************************************************************/
   FUNCTION f_get_cobliga_cero (
      pnpoliza   IN       NUMBER,
      pplan      IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam     VARCHAR2 (200);
      vpasexec   NUMBER (8)     := 1;
      vobject    VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_get_cobliga_cero';
      vconta     NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO vconta
        FROM garanseg g, seguros s, riesgos r
       WHERE g.sseguro = s.sseguro
         AND g.ffinefe IS NULL
         AND g.nriesgo = r.nriesgo
         AND s.sseguro = r.sseguro
         AND r.nriesgo = NVL (pplan, r.nriesgo)
         AND s.npoliza = pnpoliza
         AND s.ncertif = 0
         AND g.cgarant = pcgarant;

      RETURN vconta;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_get_cobliga_cero;

   /***************************************************************************
      -- BUG 23075 - 27/07/2012 - FPG
      Recupera las cuentas corrientes del pagador / gestor de cobro
      param in psperson  : Código personas
      param in psseguro  : Número seguro
      param out mensajes : Mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_pagadorccc (
      psperson   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes,
      psseguro   IN       NUMBER DEFAULT NULL,
      pmandato   IN       VARCHAR2 DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      vumerr     NUMBER;
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.F_Get_PagadorCCC';
      squery     VARCHAR2 (3000);
      cur        sys_refcursor;
   BEGIN
      IF pac_iax_produccion.vpmode = 'POL'
      THEN
         squery :=
               'SELECT sperson, cbancar, Tcbancar, ctipban, snip, cbancar_1, cdefecto FROM ( '
            || 'SELECT PER.SPERSON, PER.CBANCAR,'
            || ' PAC_MD_COMMON.F_FormatCCC(PER.CTIPBAN,PER.CBANCAR) Tcbancar, PER.CTIPBAN,'
            || ' PS.SNIP,PER.CBANCAR cbancar_1, per.cdefecto cdefecto'
            || 'FROM CCC PER , PERSONAS PS'
            || ' WHERE PER.SPERSON = PS.SPERSON'
            || 'AND PER.SPERSON = '
            || psperson
            || ' AND PER.FBAJA IS NULL'
            || '                UNION'
            || ' SELECT g.SPERSON, s.CBANCAR,'
            || ' PAC_MD_COMMON.F_FormatCCC(s.CTIPBAN,s.CBANCAR) Tcbancar, s.CTIPBAN,'
            || ' PS.SNIP,s.CBANCAR cbancar_1,'
            || ' (select cdefecto from per_ccc p where p.sperson = PS.SPERSON and p.cbancar = s.cbancar and p.cagente = ps.cagente and p.ctipban = ps.ctipban) cdefecto'
            || ' FROM GESCOBROS g , PERSONAS PS, SEGUROS s'
            || 'WHERE g.SPERSON = PS.SPERSON'
            || ' AND g.sseguro = s.sseguro'
            || 'AND s.sseguro = '
            || NVL (TO_CHAR (psseguro), ' NULL')
            || ') sel ';
      ELSE
         /* bug 31208/ 0176682 En esta select solo se muestran las cuentas bancarias de la persona que le llega como parametro de entrada, que es el pagador*/
         /* de la póliza, puede ser que no este en base de datos ( al realizar un cambio de pagador)  el sperson lo tenemos en el type, no se puede acceder a estgescobrs.*/
         squery :=
               'SELECT sperson, cbancar, Tcbancar, ctipban, snip, cbancar_1, cdefecto FROM ( '
            || 'SELECT PER.SPERSON, PER.CBANCAR,'
            || ' PAC_MD_COMMON.F_FormatCCC(PER.CTIPBAN,PER.CBANCAR) Tcbancar, PER.CTIPBAN,'
            || ' PS.SNIP,PER.CBANCAR cbancar_1, per.cdefecto cdefecto'
            || ' FROM estper_ccc PER ,estper_personas PS'
            || ' WHERE PER.SPERSON = PS.SPERSON'
            || ' AND PER.SPERSON = '
            || psperson
            || ' AND PER.FBAJA IS NULL ) sel ';
      END IF;

      /* RSA MANDATOS*/
      IF NVL (pmandato, 'N') = 'S'
      THEN
         IF pac_iax_produccion.vpmode = 'POL'
         THEN
            squery :=
                  squery
               || ' WHERE EXISTS (SELECT 1 from  MANDATOS MA
                                          WHERE MA.CBANCAR = sel.cbancar
                                          AND MA.SPERSON = sel.sperson
                                          AND  ma.cestado IN (0,1))';
         ELSE
            squery :=
                  squery
               || ' WHERE EXISTS (SELECT 1 from  ESTMANDATOS MA
                                          WHERE MA.CBANCAR = sel.cbancar
                                          AND MA.SPERSON = sel.sperson
                                          AND  ma.cestado IN (0,1))';
         END IF;
      END IF;

      squery := squery || ' ORDER BY CDEFECTO DESC';
      vumerr :=
         pac_log.f_log_consultas (squery,
                                  'PAC_MD_PRODUCCION.f_get_pagadorccc',
                                  1
                                 );
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_pagadorccc;

   /* BUG22839:DRA:26/09/2012:Inici*/
   FUNCTION f_es_col_admin (
      psseguro         IN       NUMBER,
      ptablas          IN       VARCHAR2 DEFAULT 'SEG',
      es_col_admin     OUT      NUMBER,
      es_certif_cero   OUT      NUMBER,
      mensajes         IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (100)  := 'PAC_MD_PRODUCCION.f_es_col_admin';
      vparam        VARCHAR2 (2000)
         := 'parámetros - psseguro: ' || psseguro || ' - ptablas: '
            || ptablas;
      vnumerr       NUMBER          := 0;
      vpasexec      NUMBER          := 0;
      vnpoliza      NUMBER;
      vsseguro      NUMBER;
      v_ssegpol     NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Ini 13888 -- 18/05/2020
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT sseguro, npoliza, ssegpol
              INTO vsseguro, vnpoliza, v_ssegpol
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               SELECT a.sseguro, a.npoliza, a.ssegpol
                 INTO vsseguro, vnpoliza, v_ssegpol
                 FROM estseguros a
                WHERE a.ssegpol = psseguro
                  AND a.sseguro = (SELECT MAX (b.sseguro)
                                     FROM estseguros b
                                    WHERE b.ssegpol = a.ssegpol);
         END;
      -- Ini 13888 -- 18/05/2020
      ELSE
         SELECT sseguro, npoliza, sseguro
           INTO vsseguro, vnpoliza, v_ssegpol
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      p_tab_error (f_sysdate,
                   f_user,
                   'pac_md_produccion',
                   1,
                   'f_es_col_admin-->',
                      'vsseguro, vnpoliza, v_ssegpol'
                   || vsseguro
                   || ','
                   || vnpoliza
                   || ','
                   || v_ssegpol
                   || 'psseguro '
                   || psseguro
                  );
      vpasexec := 1;
      es_col_admin := pac_seguros.f_es_col_admin (vsseguro, ptablas);
      vpasexec := 2;
      es_certif_cero := pac_seguros.f_get_escertifcero (vnpoliza);

      /* Bug 22839 - RSC - 20/11/2012 - LCOL - Funcionalidad Certificado 0*/
      IF     ptablas = 'EST'
         AND es_certif_cero > 0
         AND pac_seguros.f_get_escertifcero (NULL, v_ssegpol) = 1
      THEN
         es_col_admin := 0;
      END IF;

      /* Fin Bug 22839*/
      IF es_col_admin > 1
      THEN
         vnumerr := 1;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, es_col_admin);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_es_col_admin;

   FUNCTION f_emitir_col_admin (
      psseguro          IN       NUMBER,
      psproces          IN OUT   NUMBER,
      pcontinuaemitir   OUT      NUMBER,
      mensajes          IN OUT   t_iax_mensajes,
      ppasapsu          IN       NUMBER DEFAULT 1,
      pskipfusion       IN       NUMBER DEFAULT 0,
      preteni                    NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      vobjectname        VARCHAR2 (100)
                                    := 'PAC_MD_PRODUCCION.f_emitir_col_admin';
      vparam             VARCHAR2 (2000)
                                     := 'parámetros - psseguro: ' || psseguro;
      vnumerr            NUMBER;
      vpasexec           NUMBER                       := 0;
      v_mov              NUMBER;
      v_mov_n            NUMBER;
      v_nsuplem          NUMBER;
      v_issuplem_0       BOOLEAN;
      v_issuplem         BOOLEAN;
      onpoliza           NUMBER;
      oncertif           NUMBER;
      /* JLB  - I- 23074*/
      xnfracci           recibos.nfracci%TYPE;
      xnanuali           recibos.nanuali%TYPE;
      vcagastexp         seguroscol.cagastexp%TYPE    := 0;
      vcperiogast        seguroscol.cperiogast%TYPE   := 0;
      viimporgast        seguroscol.iimporgast%TYPE   := 0;
      vcforpag           seguros.cforpag%TYPE;
      /* JLB - F -23074*/
      v_sseguro          NUMBER;
      v_antes            VARCHAR2 (1000);
      v_despues          VARCHAR2 (1000);
      t_recibo           t_lista_id                   := t_lista_id ();
      v_sproces          NUMBER;
      v_nprolin          NUMBER (6);
      v_isaltacol        BOOLEAN;
      v_nrecunif         NUMBER;
      vparampsu          NUMBER;
      vttext             VARCHAR2 (1000);
      v_creteni          NUMBER (2);
      v_cmotmov          NUMBER (3);
      v_valor            NUMBER;
      v_resp_4821        NUMBER;
      v_numrec           NUMBER;
      v_fvencim          DATE;
      /* Bug 23853 - RSC - 17/12/201*/
      v_ffefecto         DATE;
      /* Fin bug 23853*/
      v_numcert          NUMBER;
      xsmovrec           movrecibo.smovrec%TYPE;
      xfmovim            DATE;
      xfemisio           DATE;
      xfefecto           DATE;
      /* Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
      w_retorn           NUMBER;
      p_testpol          VARCHAR2 (400);
      p_cestpol          NUMBER;
      p_cnivelbpm        NUMBER;
      p_tnivelbpm        VARCHAR2 (50);
      vquery             VARCHAR2 (2000);
      v_mov_aux          NUMBER;
      v_entra            BOOLEAN;
      /* Bug 25583 - RSC - 29/01/2013*/
      v_primin_gen       NUMBER;
      /* Fin bug 25583*/
      v_femisio          DATE;
      /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificación cursor)*/
      v_fecha            DATE;
      /* Fin Bug 26070*/
      /* Bug 26070 - ECP- 21/02/2013*/
      v_commit           NUMBER;
      /* Fin Bug 26070*/
      v_fefecto          DATE;
      v_fcaranu          DATE;
      v_cuotas           NUMBER;
      v_frenova          DATE;
      /* BUG 0026341 - 12/03/2013 - JMF*/
      v_generadorec      NUMBER;
      /* Fin bug 22839*/
      /*Ini Bug 26488 --ECP -- 21/05/2013*/
      v_bloq             BOOLEAN;
      /*Fin Bug 26488 --ECP -- 21/05/2013*/
      v_movnoanul        NUMBER;
      /*Bug 39530-KJSC-08/03/2016 Esta generando error '-2292-ORA-02292: integrity constraint (AXIS.RECIBOS_MOVSEGURO_FK) violated - child record found'*/
      /*al tratar de borrar el movseguro cuando se rehabilita los certificados-.*/
      numrecibos         NUMBER;

      CURSOR c_cert0
      IS
         SELECT sseguro, csituac, creteni, npoliza, ncertif, fefecto,
                cempres, sproduc, nsuplem,
                pac_monedas.f_moneda_producto (sproduc) moneda
           FROM seguros
          WHERE sseguro = psseguro;

      /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificación cursor)*/
      CURSOR c_certn (
         pc_npoliza   IN   NUMBER,
         p_fecha      IN   DATE,
         pc_creteni   IN   NUMBER
      )
      IS
         SELECT sseguro, csituac, creteni, npoliza, ncertif
           FROM seguros
          WHERE npoliza = pc_npoliza
            AND ncertif <> 0
            AND (   csituac IN (4, 5)
                 OR (    csituac = 2
                     AND EXISTS (
                            SELECT 1
                              FROM movseguro
                             WHERE sseguro = seguros.sseguro
                               AND cmovseg = 3
                               AND fmovimi >= p_fecha
                               /* Bug 26151 - APD - 01/03/2013*/
                               AND nmovimi NOT IN (
                                      SELECT nmovimi_cert
                                        FROM detmovsegurocol
                                       WHERE sseguro_0 = psseguro
                                         AND sseguro_cert = seguros.sseguro)
                                                                            /* fin Bug 26151 - APD - 01/03/2013*/
                         )
                    )
                )
            AND (   (creteni = 0 AND pc_creteni = 0)
                 OR (creteni = creteni AND pc_creteni <> 0)
                );

      /* Bug 26151 - APD - 07/03/2013*/
      CURSOR c_rie (pcsseguro IN seguros.sseguro%TYPE, pctablas IN VARCHAR2)
      IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = pcsseguro AND pctablas IS NULL
         UNION ALL
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = pcsseguro AND pctablas = 'EST';

      /* BUG 0026070 - 05/03/2013 - JMF*/
      v_ctipcoa          seguros.ctipcoa%TYPE;

      TYPE data_t IS TABLE OF t_lista_id
         INDEX BY PLS_INTEGER;

      v_array            data_t;
      v_total_pos        NUMBER;
      v_total_neg        NUMBER;
      v_totalp           NUMBER;
      v_totaln           NUMBER;
      v_tiprec           NUMBER;
      v_plsql            VARCHAR2 (1000);
      v_certifs_tratar   NUMBER;
      v_registro         NUMBER                       := 1;
      v_botonemite       BOOLEAN                      := FALSE;
      v_cmotmov_prev     NUMBER;
      /*Bug 29665/168265 - 03/03/2014 - AMC*/
      v_haymovs          NUMBER;
      v_jobtype          NUMBER;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*Ini Bug 26488 -- ECP --21/05/2013*/
      v_bloq := TRUE;
      /*Fin Bug 26488 -- ECP --21/05/2013*/
      v_isaltacol := pac_iax_produccion.isaltacol;
      vpasexec := 1;

      /* ini BUG 0026070 - 15/02/2013 - JMF*/
      DECLARE
         v_csituac   seguros.csituac%TYPE;
         v_femisio   movseguro.femisio%TYPE;
         v_cmotven   movseguro.cmotven%TYPE;
      BEGIN
         /*BUG26488/147026 - DCT - 16/06/2013 - Inicio -  Añadir creteni*/
         SELECT csituac, creteni
           INTO v_csituac, v_creteni
           FROM seguros
          WHERE sseguro = psseguro;

         IF v_csituac = 0
         THEN
            /* No se ha podido emitir el colectivo, la póliza se encuentra en proceso de emisión*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9904990);
            RAISE e_object_error;
         END IF;

         /*Estado que refleja  que la póliza se encuentra ejecutando un proceso interno*/
         IF v_creteni = 20
         THEN
            /* No se ha podido emitir el colectivo, la póliza se encuentra ejecutando un proceso interno*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9905704);
            RAISE e_object_error;
         END IF;

         /*BUG27048/150505 - DCT - 05/08/2013 - Inicio -*/
         /*Estado que refleja  que la póliza se encuentra  en proceso de emisión.*/
         IF v_creteni = 21
         THEN
            /* No se ha podido emitir el colectivo, la póliza se encuentra en proceso de emisión*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9905817);
            v_botonemite := TRUE;
            RAISE e_object_error;
         END IF;

         /*BUG27048/150505 - DCT - 05/08/2013 - Fin-*/
         /* Bug 30448/0169858 - APD - 17/03/2014*/
         /*Estado que refleja  que la póliza se encuentra  en proceso de ejecucion suplementos diferidos.*/
         IF v_creteni = 22
         THEN
            /* No se ha podido emitir el colectivo, la póliza se encuentra en proceso de ejecución suplementos diferidos*/
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9906629);
            v_botonemite := TRUE;
            RAISE e_object_error;
         END IF;

         /* fin Bug 30448/0169858 - APD - 17/03/2014*/
         /*BUG26488/147026 - DCT - 16/06/2013 - Fin -  Añadir creteni*/
         /* Si está en csituac = 5 --> Propuesta de suplemento. Pero tenemos que distinguir*/
         /* de si está en propuesta de suplemento por un Abrir suplemento o por un suplemento hecho en el 0 y retenido.*/
         /* Si femisio es NULL y el cmotven está a NULL es que el suplemento en el cero está pendiente de emisión y*/
         /* es un suplemento normal. De esta forma evitaremos que aparezca el botón Emitir Colectivo y el Abrir Suplemento.*/
         IF v_csituac IN (4, 5)
         THEN
            SELECT femisio, cmotven
              INTO v_femisio, v_cmotven
              FROM movseguro
             WHERE sseguro = psseguro AND nmovimi =
                                                   (SELECT MAX (nmovimi)
                                                      FROM movseguro
                                                     WHERE sseguro = psseguro);

            IF v_femisio IS NULL AND v_cmotven IS NULL
            THEN
               /* La póliza no esta en situación para emitir el colectivo*/
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9904990);
               RAISE e_object_error;
            END IF;
         END IF;
      END;

      /* fin BUG 0026070 - 15/02/2013 - JMF*/
      IF psproces IS NULL
      THEN
         vnumerr :=
            f_procesini (pac_md_common.f_get_cxtusuario,
                         pac_md_common.f_get_cxtempresa,
                         'EMITIR_POLIZA_COL',
                         f_axis_literales (9904239,
                                           pac_md_common.f_get_cxtidioma
                                          ),
                         v_sproces
                        );
      ELSE
         v_sproces := psproces;
      END IF;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      FOR r0 IN c_cert0
      LOOP
         IF r0.csituac = 5
         THEN
            v_issuplem_0 := TRUE;
         ELSE
            v_issuplem_0 := FALSE;
         END IF;

         vpasexec := 2;

         SELECT NVL (MAX (nmovimi), 1)
           INTO v_mov
           FROM movseguro
          WHERE sseguro = r0.sseguro;

         /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias*/
         BEGIN
            SELECT m.fmovimi
              INTO v_fecha
              FROM seguros s, movseguro m
             WHERE s.npoliza = r0.npoliza
               AND s.ncertif = 0
               AND s.sseguro = m.sseguro
               AND m.cmotmov = 996
               AND m.cmotven = 998
               AND m.nmovimi =
                      (SELECT MAX (m2.nmovimi)
                         FROM movseguro m2
                        WHERE m2.sseguro = m.sseguro
                          AND m2.cmotmov = m.cmotmov
                          AND m2.cmotven = 998);
         /* de abrir suplemento*/
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT m.fefecto
                    INTO v_fecha
                    FROM seguros s, movseguro m
                   WHERE s.npoliza = r0.npoliza
                     AND s.ncertif = 0
                     AND s.sseguro = m.sseguro
                     AND m.cmotmov = 100;
               /* de alta de colectivo (cobro anticipado)*/
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_fecha := f_sysdate;
               END;
         END;

         /* Fin Bug 26070*/
         vpasexec := 3;
         v_entra := FALSE;

         /* Bug 26151 - APD - 07/03/2013 - se añade el parametro pc_reteni = 1*/
         /* al cursor para que busque todos los n certificados sin tener en cuenta*/
         /* su creteni, para asÃ­ poder mostrar el mensaje*/
         FOR rn IN c_certn (r0.npoliza, v_fecha, 1)
         LOOP
            /* si todos los n certificados tienen creteni = 0, entonces v_etra := TRUE*/
            IF rn.creteni = 0
            THEN
               /* Bug 29665/163095 - 15/01/2014 - AMC*/
               /* pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 140598);*/
               v_entra := TRUE;
            /*EXIT;*/
            ELSIF rn.creteni = 2
            THEN
               /* si se encuentra un certificado retenido no se permite continuar*/
               /* con la emision del certifcado 0 y se muestra el mensaje*/
               vnumerr := 9906655;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               /*               vttext := f_axis_literales(102829) || f_formatopolseg(rn.sseguro);*/
               /*               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vttext);*/
               /*Ini Bug 26488 -- ECP --21/05/2013*/
               v_bloq := FALSE;
               /*Fin Bug 26488 -- ECP --21/05/2013*/
               EXIT;
            /*Bug 29358/161160 - 12/12/2013 - AMC*/
            ELSIF rn.creteni = 1
            THEN
               /* si se encuentra un certificado retenido no se permite continuar*/
               /* con la emision del certifcado 0 y se muestra el mensaje*/
               vnumerr := 9906656;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               /*               vttext := f_axis_literales(102829) || f_formatopolseg(rn.sseguro);*/
               /*               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, vttext);*/
               /*Ini Bug 26488 -- ECP --21/05/2013*/
               v_bloq := FALSE;
               /*Fin Bug 26488 -- ECP --21/05/2013*/
               EXIT;
            /*Fi Bug 29358/161160 - 12/12/2013 - AMC*/
            END IF;
         END LOOP;

         /* DRA:30/06/2014: Miramos si tiene movimientos ese V_MOV y no entra,*/
         /* porque puede haber petado anteriormente, asÃ­ que lo hacemos entrar*/
         /* para que acabe el trabajo, por ejemplo, agrupar los recibos generados*/
         IF NOT v_entra
         THEN
            SELECT COUNT (1)
              INTO v_haymovs
              FROM detmovsegurocol
             WHERE sseguro_0 = r0.sseguro AND nmovimi_0 = v_mov;

            IF v_haymovs > 0
            THEN
               v_entra := TRUE;
            END IF;
         END IF;

         /* fin Bug 26151 - APD - 07/03/2013*/
         /*Ini Bug 26488 -- ECP --21/05/2013*/
         IF (v_entra OR v_mov = 1) AND v_bloq
         THEN
            /*BUG18926 - JTS - 15/07/2011*/
            /*Fin Bug 26488 -- ECP --21/05/2013*/
            IF r0.csituac IN (4, 5)
            THEN
               vpasexec := 4;

               /*******************************************************************
               vnumerr := pac_md_produccion.f_emitir(r0.sseguro, v_mov, v_issuplem_0, onpoliza,
               mensajes, v_sproces);
               IF vnumerr <> 0 THEN
               mensajes := NULL;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
               END IF;
               *******************************************************************/
               /*Actuem segons l'estat de la proposta*/
               IF r0.creteni = 2
               THEN
                  /*Proposta pendent d'autorització => No es pot emetre la proposta.*/
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 140598);
                  RAISE e_object_error;
               ELSIF r0.creteni IN (3, 4)
               THEN
                  /*Proposta anulada o rebutjada => No es pot emetre la proposta.*/
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151177);
                  RAISE e_object_error;
               ELSIF r0.creteni = 1
               THEN
                  vpasexec := 41;
                  vparampsu :=
                           pac_parametros.f_parproducto_n (r0.sproduc, 'PSU');

                  IF NVL (vparampsu, 0) = 0
                  THEN
                     /*Proposta retinguda => Abans d'emetre-la comprovem que no tingui errors en l'emissió*/
                     FOR cr IN c_rie (r0.sseguro, NULL)
                     LOOP
                        vnumerr :=
                           pac_motretencion.f_risc_retingut
                                                           (r0.sseguro,
                                                            v_mov,
                                                            NVL (cr.nriesgo,
                                                                 1),
                                                            5
                                                           );

                        IF vnumerr <> 0
                        THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                                 1,
                                                                 151237
                                                                );
                           RAISE e_object_error;
                        END IF;
                     END LOOP;

                     vpasexec := 42;
                     /*Com que es tractava d'una retenció voluntaria, l'acceptem.*/
                     vttext :=
                        f_axis_literales (151726,
                                          pac_md_common.f_get_cxtidioma
                                         );
                     vnumerr :=
                        pac_motretencion.f_desretener (r0.sseguro,
                                                       v_mov,
                                                       vttext
                                                      );

                     IF vnumerr <> 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              vnumerr
                                                             );
                        RAISE e_object_error;
                     END IF;
                  ELSE
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           1000129
                                                          );
                     RAISE e_object_error;
                  END IF;
               END IF;

               vpasexec := 43;

               IF r0.csituac = 5
               THEN
                  v_nsuplem := r0.nsuplem + 1;
               ELSE
                  v_nsuplem := r0.nsuplem;
               END IF;

               vpasexec := 44;

               /* Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
               IF     NVL (pac_parametros.f_parproducto_n (r0.sproduc, 'PSU'),
                           0
                          ) = 1
                  AND ppasapsu = 1
               THEN
                  /* Fin Bug 22839*/
                  vnumerr :=
                     pac_psu.f_inicia_psu ('POL',
                                           r0.sseguro,
                                           5,
                                           pac_md_common.f_get_cxtidioma,
                                           v_creteni
                                          );

                  IF vnumerr <> 0
                  THEN
                     mensajes := NULL;
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           vnumerr
                                                          );
                     RAISE e_object_error;
                  END IF;

                  vpasexec := 45;
                  /* Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
                  w_retorn :=
                     pac_psu.f_get_colec_psu (r0.sseguro,
                                              v_mov,
                                              1,
                                              pac_md_common.f_get_cxtidioma,
                                              'POL',
                                              vquery,
                                              p_testpol,
                                              p_cestpol,
                                              p_cnivelbpm,
                                              p_tnivelbpm
                                             );

                  /*IF NVL(v_creteni, 0) <> 0 THEN*/
                  IF NVL (p_cestpol, 0) = 1
                  THEN
                     /* Fin bug 22839*/
                     mensajes := NULL;
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           9900989
                                                          );

/************/
                     FOR psu IN (SELECT d.tcontrol
                                   FROM psucontrolseg c, psu_descontrol d
                                  WHERE c.sseguro = r0.sseguro
                                    AND c.nmovimi = v_mov
                                    AND c.cautrec = 0
                                    AND d.ccontrol = c.ccontrol
                                    AND d.cidioma =
                                                 pac_md_common.f_get_cxtidioma)
                     LOOP
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              0,
                                                              psu.tcontrol
                                                             );
                     END LOOP;

/************/
                     UPDATE seguros
                        SET creteni = NVL (v_creteni, 0)
                      WHERE sseguro = r0.sseguro;

                     COMMIT;
                     RETURN 1;
                  ELSE
                     v_creteni := 0;
                  END IF;
               /* Bug 22839 - RSC - 19/11/2012 - LCOL_T010-LCOL - Funcionalidad Certificado 0*/
               END IF;

               /* Fin bug 22839*/
               vpasexec := 46;

               /*IF r0.csituac = 4 THEN*/
               /* Bug 29665/163854 - 22/01/2014 - AMC*/
               /*  UPDATE movseguro m*/
               /*     SET m.femisio = f_sysdate*/
               /*   WHERE m.sseguro = r0.sseguro*/
               /*     AND m.nmovimi = v_mov;*/
               /*BUG27048/150505 - DCT - 05/08/2013 - Inicio -*/
               IF preteni = 1
               THEN
                  pac_seguros.p_modificar_seguro (r0.sseguro, 21);
               END IF;
            /*BUG27048/150505 - DCT - 05/08/2013 - Fin -*/
            /*END IF;*/
            /*  UPDATE seguros*/
            /*     SET csituac = 0,*/
            /*         nsuplem = v_nsuplem*/
            /*   WHERE sseguro = r0.sseguro;*/
            /* Fi Bug 29665/163854 - 22/01/2014 - AMC*/
            /* Bug 23940 - APD - 15/11/2012 - si la poliza est?n*/
            /* csituac = 4.-Prop. Alta, por defecto, se debe dar*/
            /* de alta el colectivo como bloqueado*/
            /*
            IF r0.csituac = 4 THEN
            vnumerr := pac_propio.f_act_cbloqueocol(r0.sseguro);
            END IF;*/
            /* fin Bug 23940 - APD - 15/11/2012*/
            ELSE
               onpoliza := r0.npoliza;
            END IF;

            vpasexec := 5;
            pac_iax_produccion.isaltacol := FALSE;
            /*Bug 29665/163095 - 14/01/2014 - AMC*/
            vnumerr :=
               pac_md_produccion.f_num_certif (r0.npoliza,
                                               psseguro,
                                               1,
                                               v_certifs_tratar,
                                               mensajes
                                              );

            IF     NVL
                      (pac_md_param.f_get_parproducto_n
                                                      (r0.sproduc,
                                                       'DIFIERE_EMITECOL_JOB',
                                                       mensajes
                                                      ),
                       0
                      ) = 1
               AND NVL
                      (pac_md_param.f_get_parproducto_n
                                                      (r0.sproduc,
                                                       'NUM_DIFIERE_EMITECOL',
                                                       mensajes
                                                      ),
                       0
                      ) < v_certifs_tratar
            THEN
               /*               pac_iobj_mensajes.crea_nuevo_mensaje*/
               /*                                            (mensajes, 1, 0,*/
               /*                                             f_axis_literales(9906420,*/
               /*                                                              pac_md_common.f_get_cxtidioma)*/
               /*                                             || '. '*/
               /*                                             || f_axis_literales*/
               /*                                                                (9000493,*/
               /*                                                                 pac_md_common.f_get_cxtidioma)*/
               /*                                             || ': ' || v_sproces);*/
               pcontinuaemitir := 2;
               v_plsql :=
                     'declare num_err NUMBER; begin '
                  || CHR (10)
                  || 'num_err:= pac_contexto.f_inicializarctx('
                  || CHR (39)
                  || f_user
                  || CHR (39)
                  || ');'
                  || CHR (10)
                  || ' num_err:=PAC_MD_PRODUCCION.F_LANZAJOB_EMITECOL_ADMIN('
                  || psseguro
                  || ','
                  || NVL (TO_CHAR (v_sproces), 'null')
                  || ','
                  || NVL (TO_CHAR (pcontinuaemitir), 'null')
                  || ','
                  || NVL (TO_CHAR (ppasapsu), 'null')
                  || ','
                  || NVL (TO_CHAR (pskipfusion), 'null')
                  || '); '
                  || CHR (10)
                  || ' end;';
               v_jobtype :=
                  NVL (pac_md_param.f_parinstalacion_nn ('JOB_TYPE', mensajes),
                       0
                      );

               IF v_jobtype = 0
               THEN
                  vnumerr := pac_jobs.f_ejecuta_job (NULL, v_plsql, NULL);
               ELSIF v_jobtype IN (1, 2)
               THEN
                  vnumerr :=
                     pac_jobs.f_inscolaproces (1,
                                               v_plsql,
                                                  'Parámetros: psseguro='
                                               || psseguro
                                               || '; psproces='
                                               || NVL (TO_CHAR (v_sproces),
                                                       'null'
                                                      ),
                                               psseguro
                                              );
               END IF;

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje
                             (mensajes,
                              1,
                              0,
                              f_axis_literales (9905979,
                                                pac_md_common.f_get_cxtidioma
                                               )
                             );
                  RAISE e_object_error;
               ELSE
                  pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            0,
                               f_axis_literales (9906420,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || f_axis_literales (9000493,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ': '
                            || v_sproces
                           );
               END IF;
            ELSE
               /* Bug 26151 - APD - 07/03/2013 - se añade el parametro pc_reteni = 0*/
               /* al cursor para que busque solo los n certificados con creteni = 0*/
               FOR rn IN c_certn (r0.npoliza, v_fecha, 0)
               LOOP
                  /* fin Bug 26151 - APD - 07/03/2013*/
                  vpasexec := 6;
                  onpoliza := rn.npoliza;
                  oncertif := rn.ncertif;
                  v_sseguro := rn.sseguro;
                  vpasexec := 7;

                  SELECT NVL (MAX (nmovimi), 1)
                    INTO v_mov_n
                    FROM movseguro
                   WHERE sseguro = rn.sseguro;

                  IF rn.csituac = 5
                  THEN
                     v_issuplem := TRUE;
                  ELSE
                     v_issuplem := FALSE;
                  END IF;

                  /* Bug 23940 - APD - 15/11/2012 - si la poliza est?n*/
                  /* csituac = 4.-Prop. Alta, por defecto, se debe dar*/
                  /* de alta el colectivo como bloqueado*/
                  /*
                  IF rn.csituac = 4 THEN
                  vnumerr := pac_propio.f_act_cbloqueocol(rn.sseguro);
                  END IF;*/
                  /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias*/
                  IF rn.csituac IN (4, 5)
                  THEN
                     /* Fin Bug 26070*/
                     /* fin Bug 23940 - APD - 15/11/2012*/
                     vpasexec := 8;
                     v_commit := 0;
                     vnumerr :=
                        pac_md_produccion.f_emitir (rn.sseguro,
                                                    v_mov_n,
                                                    v_issuplem,
                                                    onpoliza,
                                                    mensajes,
                                                    v_sproces,
                                                    v_commit
                                                   );

                     /* Bug 26070 -- ECP-- 21/02/2013*/
                     IF vnumerr <> 0
                     THEN
                        /*mensajes := NULL;*/
                        /*pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);*/
                        IF mensajes IS NOT NULL
                        THEN
                           IF mensajes.COUNT > 0
                           THEN
                              /* Puede que la emisin de los n-certificados d error y este no lo devuelve, pero queda*/
                              /*  almacenado en mensajes*/
                              /*mensajes := NULL;*/
                              pac_iobj_mensajes.crea_nuevo_mensaje
                                 (mensajes,
                                  1,
                                  9900724,
                                     f_axis_literales
                                                (140730,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                  || '. '
                                  || f_axis_literales
                                                (9900724,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                  || ' '
                                  || v_sproces
                                 );
                           END IF;
                        END IF;

                        RAISE e_object_error;
                     END IF;
                  /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias*/
                  END IF;

                  /* Fin bug 26070*/
                  vpasexec := 9;

                  BEGIN
                     INSERT INTO detmovsegurocol
                                 (sseguro_0, nmovimi_0, sseguro_cert,
                                  nmovimi_cert
                                 )
                          VALUES (r0.sseguro, v_mov, rn.sseguro,
                                  v_mov_n
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        p_tab_error (f_sysdate,
                                     f_user,
                                     vobjectname,
                                     vpasexec,
                                     vparam,
                                     ' err=' || SQLCODE || ' ' || SQLERRM
                                    );
                  END;

                  vpasexec := 10;

                  SELECT npoliza, ncertif
                    INTO onpoliza, oncertif
                    FROM seguros
                   WHERE sseguro = rn.sseguro;

                  vpasexec := 101;

                  SELECT cmotmov
                    INTO v_cmotmov
                    FROM movseguro
                   WHERE sseguro = rn.sseguro AND nmovimi = v_mov_n;

                  vpasexec := 11;

                  BEGIN
                     INSERT INTO detmovseguro
                                 (sseguro, nmovimi, cmotmov, nriesgo,
                                  cgarant, cpregun, tvalora,
                                  tvalord
                                 )
                          VALUES (r0.sseguro, v_mov, v_cmotmov, 0,
                                  0, 0, NULL,
                                  /* f_axis_literales(103289, pac_md_common.f_get_cxtidioma),*/
                                  SUBSTR (onpoliza || '-' || oncertif, 1,
                                          1000)
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE detmovseguro
                           SET tvalord =
                                  SUBSTR (   tvalord
                                          || '; '
                                          || onpoliza
                                          || '-'
                                          || oncertif,
                                          1,
                                          1000
                                         )
                         WHERE sseguro = r0.sseguro
                           AND nmovimi = v_mov
                           AND cmotmov = v_cmotmov
                           AND nriesgo = 0
                           AND cgarant = 0
                           AND cpregun = 0;
                  END;

                  IF v_sproces IS NOT NULL
                  THEN
                     vpasexec := 12;
                     v_nprolin := NULL;
                     vnumerr :=
                        f_proceslin (v_sproces,
                                        f_axis_literales (151301,
                                                          f_usu_idioma)
                                     || ' '
                                     || onpoliza
                                     || '-'
                                     || oncertif,
                                     v_sseguro,
                                     v_nprolin,
                                     4
                                    );
                  END IF;

                  FOR i IN
                     (SELECT   s.sseguro, s.cidioma,
                               pac_isqlfor.f_max_nmovimi (s.sseguro) nmovimi,
                               ppc.ctipo
                          FROM prod_plant_cab ppc, seguros s
                         WHERE s.sseguro = rn.sseguro
                           AND s.sproduc = ppc.sproduc
                           AND ppc.ctipo = 41
                      GROUP BY s.sseguro, s.cidioma, ppc.ctipo)
                  LOOP
                     pac_isql.p_ins_doc_diferida (i.sseguro,
                                                  i.nmovimi,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  i.cidioma,
                                                  i.ctipo
                                                 );
                  END LOOP;

                  /**/
                  COMMIT;
                  v_registro := v_registro + 1;
               END LOOP;

               COMMIT;
               vpasexec := 13;

               SELECT MAX (nmovimi)
                 INTO v_mov_aux
                 FROM garanseg g
                WHERE sseguro = r0.sseguro AND nriesgo = 1 AND ffinefe IS NULL;

               /*24058:DCT:08/11/2012:Inici*/
               vnumerr :=
                  pac_tarifas.f_tarifar_riesgo_tot (NULL,
                                                    r0.sseguro,
                                                    1,
                                                    NVL (v_mov_aux, 1),
                                                    r0.moneda,
                                                    r0.fefecto
                                                   );

               IF vnumerr <> 0
               THEN
                  mensajes := NULL;
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;

               /*24058:DCT:08/11/2012:Fin*/
               /* Valor prima mÃ­nima del certificat 0*/
               vnumerr :=
                  pac_preguntas.f_get_pregunpolseg (r0.sseguro,
                                                    4821,
                                                    'SEG',
                                                    v_resp_4821
                                                   );
               vpasexec := 131;

               /* Bug 25583 - RSC - 29/01/2013*/
               SELECT COUNT (1)
                 INTO v_primin_gen
                 FROM recibos r, detrecibos d
                WHERE r.sseguro = r0.sseguro
                  AND d.nrecibo = r.nrecibo
                  AND r.ctiprec = 0
                  AND r.ctiprec = 0
                  AND d.cgarant = 400
                  AND d.cconcep = 0
                  AND d.iconcep <> 0
                  AND f_cestrec (d.nrecibo, f_sysdate) <> 2;

               /* BUG 0026341 - 12/03/2013 - JMF*/
               SELECT COUNT (1)
                 INTO v_generadorec
                 FROM recibos r, detmovsegurocol d
                WHERE r.sseguro = d.sseguro_cert
                  AND r.nmovimi = d.nmovimi_cert
                  AND d.sseguro_0 = r0.sseguro
                  AND d.nmovimi_0 = v_mov
                  AND NOT EXISTS (SELECT a.nrecibo
                                    FROM adm_recunif a
                                   WHERE a.nrecibo = r.nrecibo);

               SELECT MAX (ROWNUM)
                 INTO v_movnoanul
                 FROM movseguro
                WHERE sseguro = r0.sseguro
                  AND cmovseg <> 52
                  AND nmovimi <= v_mov;

               /*Bug 29665/168265 - 03/03/2014 - AMC*/
               SELECT cmotmov
                 INTO v_cmotmov_prev
                 FROM movseguro
                WHERE sseguro = r0.sseguro
                  AND nmovimi = DECODE (v_mov, 1, 1, v_mov - 1);

               /* Ini 26488 -- ECP -- 19/03/2013*/
               IF    (v_primin_gen = 0 AND (v_mov <= 2 OR v_movnoanul <= 2))
                  OR v_cmotmov_prev = 674
               THEN
                  /*Fi Bug 29665/168265 - 03/03/2014 - AMC*/
                  /* La emisi??olectivo solo genera recibo de prima m?ma la primera vez. El resto de veces ya lo monta*/
                  /* la cartera. Por eso podemos ir a vdetrecibos e ir a buscar el importe de recibos generados.*/
                  /* Fin 26488 -- ECP -- 19/03/2013*/
                  SELECT SUM (iprinet + irecfra)
                    INTO v_valor
                    FROM detmovsegurocol d, recibos r, vdetrecibos v
                   WHERE d.sseguro_0 = r0.sseguro
                     AND d.nmovimi_0 = v_mov
                     AND d.sseguro_cert = r.sseguro
                     AND d.nmovimi_cert = r.nmovimi
                     AND r.ctiprec = 0
                     AND r.nrecibo = v.nrecibo;

                  /* Fin Bug 25583*/
                  vpasexec := 132;

                  /*Ini Bug 25583 -- ECP -- 24/01/2013*/
                  IF NVL (v_valor, 0) < NVL (v_resp_4821, 0)
                  THEN
                     /* Miramos si se han generado recibos en el movimiento*/
                     SELECT COUNT (d.sseguro_cert)
                       INTO v_numcert
                       FROM detmovsegurocol d
                      WHERE d.sseguro_0 = r0.sseguro AND d.nmovimi_0 = v_mov;

                     /* Bug 25583 - ECP - 24/01/2013 Se agrega al IF AND v_numrec > 0 para controlar si existen recibo generados*/
                     /* BUG 0026341 - 12/03/2013 - JMF: canvi v_numrec per v_generadorec*/
                     IF v_numcert > 0 AND v_generadorec > 0
                     THEN
                        /* Bug 23853 - RSC - 17/12/201*/
                        /*   v_ffefecto := GREATEST(r0.fefecto, f_sysdate);*/
                        /* Fin bug 23853*/
                        SELECT MIN (r.fefecto), MAX (r.fvencim),
                               MAX (r.femisio)
                          INTO v_ffefecto, v_fvencim,
                               v_femisio
                          FROM recibos r, detmovsegurocol d
                         WHERE d.sseguro_0 = r0.sseguro
                           AND d.nmovimi_0 = v_mov
                           AND r.sseguro = d.sseguro_cert
                           AND r.nmovimi = d.nmovimi_cert
                           AND NOT EXISTS (SELECT a.nrecibo
                                             FROM adm_recunif a
                                            WHERE a.nrecibo = r.nrecibo);

                        vnumerr :=
                           pac_md_gestion_rec.f_genrec_primin_col
                                                          (r0.sseguro,
                                                           v_mov,
                                                           0,
                                                           v_femisio,
                                                           v_ffefecto,
                                                           v_fvencim,
                                                             NVL (v_resp_4821,
                                                                  0
                                                                 )
                                                           - NVL (v_valor, 0),
                                                           v_numrec,
                                                           'R',
                                                           v_sproces,
                                                           'SEG',
                                                           mensajes
                                                          );

                        IF vnumerr <> 0
                        THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                                 1,
                                                                 vnumerr
                                                                );
                           RAISE e_object_error;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               vpasexec := 14;

               /* JLB - I - 23074 Creamos recibo de gastos de emision*/
               /*Colectivo individualizado + Colectivo multiple*/
               BEGIN
                  SELECT cagastexp, cperiogast, iimporgast, cforpag,
                         fcaranu, fefecto, frenova
                    INTO vcagastexp, vcperiogast, viimporgast, vcforpag,
                         v_fcaranu, v_fefecto, v_frenova
                    FROM seguroscol sc, seguros seg
                   WHERE seg.sseguro = psseguro AND sc.sseguro = seg.sseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     vcagastexp := 0;
                     vcperiogast := 0;
                     viimporgast := 0;
               END;

               /*            IF vcagastexp = 0 OR (xctiprec NOT IN(0, 3)) THEN*/
               /* solo aplico gastos en nuevaproduccio y carteras*/
               /*or nvl(xnanuali,1)>1  -- revisar si pnmovima = 1 Ã‚Â¿? ponemos la anualidad = 1*/
               /*             RETURN 1;   -- no aplica  gastos de expedicion*/
               /*         END IF;*/
               vpasexec := 141;

               /* Bug 23853 - RSC - 17/12/201*/
               /*v_ffefecto := GREATEST(r0.fefecto, f_sysdate);*/
               /* Fin bug 23853*/
               SELECT MIN (r.fefecto), MAX (r.fvencim), MAX (r.femisio)
                 INTO v_ffefecto, v_fvencim, v_femisio
                 FROM recibos r, detmovsegurocol d
                WHERE d.sseguro_0 = r0.sseguro
                  AND d.nmovimi_0 = v_mov
                  AND r.sseguro = d.sseguro_cert
                  AND r.nmovimi = d.nmovimi_cert
                  AND NOT EXISTS (SELECT a.nrecibo
                                    FROM adm_recunif a
                                   WHERE a.nrecibo = r.nrecibo);

               vpasexec := 142;

               SELECT COUNT (d.sseguro_cert)
                 INTO v_numcert
                 FROM detmovsegurocol d
                WHERE d.sseguro_0 = r0.sseguro AND d.nmovimi_0 = v_mov;

               vpasexec := 143;

               /* BUG 0026070 - 05/03/2013 - JMF*/
               /* Si tiene Coaseguro Aceptado no genera gastos expedición*/
               SELECT NVL (MAX (ctipcoa), 0)
                 INTO v_ctipcoa
                 FROM seguros
                WHERE sseguro = r0.sseguro;

               /* Bug 25583 - ECP - 24/01/2013 Se agrega al IF AND v_numrec > 0 para controlar si existen recibo generados*/
               /* BUG 0026341 - 12/03/2013 - JMF: canvi v_numrec per v_generadorec*/
               IF v_numcert > 0 AND v_generadorec > 0 AND v_ctipcoa <> 8
               THEN
                  IF vcagastexp = 1
                  THEN
                     /* de momento es 0 and tiprec.ctiprec in (0,3) THEN*/
                     /* si aplica gastos en recibo agrupado y certificado en = 0 y tipo recibo NP o CATEREA*/
                     IF (vcperiogast = 2 AND xnfracci > 0)
                     THEN
                        /* Si fraccionamiento es anual, y la fraccion no es la primera*/
                        /* si el fraccionamiento es anual y la fracción no es la primera*/
                        /* RETURN 1;*/
                        NULL;
                     ELSE
                        IF vcperiogast = 2
                        THEN
                           /* anual*/
                           /*viimporgast := viimporgast;*/
                           NULL;
                        ELSIF vcperiogast = 1
                        THEN
                           /* segun forma de pago*/
                           SELECT CEIL
                                     (  MONTHS_BETWEEN
                                            (NVL (v_fcaranu,
                                                  NVL (v_frenova,
                                                       ADD_MONTHS (v_fefecto,
                                                                   12
                                                                  )
                                                      )
                                                 ),
                                             v_fefecto
                                            )
                                      / vtramo (-1, 291, vcforpag)
                                     )
                             INTO v_cuotas
                             FROM DUAL;

                           viimporgast := viimporgast / v_cuotas;
                        END IF;

                        vpasexec := 144;
                        /* fraccionamiento anual*/
                        vnumerr :=
                           pac_md_gestion_rec.f_genrec_gastos_expedicion
                                                                 (r0.sseguro,
                                                                  v_mov,
                                                                  0,
                                                                  v_femisio,
                                                                  v_ffefecto,
                                                                  v_fvencim,
                                                                  viimporgast,
                                                                  v_numrec,
                                                                  'R',
                                                                  v_sproces,
                                                                  'SEG',
                                                                  mensajes
                                                                 );

                        IF vnumerr <> 0
                        THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                                 1,
                                                                 vnumerr
                                                                );
                           RAISE e_object_error;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               vpasexec := 145;

               /*BUG27048/150505 - DCT - 05/08/2013 - Inicio -*/
               /*pac_seguros.p_modificar_seguro(psseguro, v_creteni);*/
               /*BUG27048/150505 - DCT - 05/08/2013 - Fin -*/
               /* deberia comprobar que sol o exista una garantia con derechos de registro?*/
               /* JLB - F  23074 Creamos recibo de gastos de emision*/
               /* Bug 25583 - ECP - 24/01/2013 Se agrega al IF AND v_numrec > 0 para controlar si existen recibo generados*/
               /* BUG 0026341 - 12/03/2013 - JMF: canvi v_numrec per v_generadorec*/
               IF v_generadorec > 0
               THEN
                  vpasexec := 146;

                  IF pskipfusion = 1
                  THEN
                     /* Resto de recibos*/
                     FOR tiprec IN (SELECT DISTINCT r.ctiprec
                                               FROM recibos r,
                                                    detmovsegurocol d
                                              WHERE r.sseguro = d.sseguro_cert
                                                AND r.nmovimi = d.nmovimi_cert
                                                AND d.sseguro_0 = r0.sseguro
                                                AND d.nmovimi_0 = v_mov
                                                AND r.ctiprec NOT IN (13, 15)
                                                AND f_cestrec_mv (r.nrecibo,
                                                                  2) = 0
                                                AND NOT EXISTS (
                                                       SELECT a.nrecibo
                                                         FROM adm_recunif a
                                                        WHERE a.nrecibo =
                                                                     r.nrecibo)
                                    UNION
                                    SELECT DISTINCT r.ctiprec
                                               FROM recibos r
                                              WHERE r.sseguro = r0.sseguro
                                                AND r.nmovimi = v_mov
                                                AND r.ctiprec NOT IN (13, 15)
                                                AND f_cestrec_mv (r.nrecibo,
                                                                  2) = 0
                                                AND NOT EXISTS (
                                                       SELECT a.nrecibo
                                                         FROM adm_recunif a
                                                        WHERE a.nrecibo =
                                                                     r.nrecibo)
                                           ORDER BY ctiprec)
                     LOOP
                        t_recibo := NULL;
                        t_recibo := t_lista_id ();
                        vpasexec := 147;
                        vpasexec := 15;

                        FOR rec IN
                           (SELECT r.nrecibo
                              FROM recibos r, detmovsegurocol d
                             WHERE r.sseguro = d.sseguro_cert
                               AND r.nmovimi = d.nmovimi_cert
                               AND r.ctiprec = tiprec.ctiprec
                               AND d.sseguro_0 = r0.sseguro
                               AND d.nmovimi_0 = v_mov
                               AND f_cestrec_mv (r.nrecibo, 2) = 0
                               AND NOT EXISTS (SELECT a.nrecibo
                                                 FROM adm_recunif a
                                                WHERE a.nrecibo = r.nrecibo)
                            UNION
                            SELECT r.nrecibo
                              FROM recibos r
                             WHERE r.sseguro = r0.sseguro
                               AND r.nmovimi = v_mov
                               AND r.ctiprec = tiprec.ctiprec
                               AND f_cestrec_mv (r.nrecibo, 2) = 0
                               AND NOT EXISTS (SELECT a.nrecibo
                                                 FROM adm_recunif a
                                                WHERE a.nrecibo = r.nrecibo)
                               AND NOT EXISTS (SELECT a.nrecunif
                                                 FROM adm_recunif a
                                                WHERE a.nrecunif = r.nrecibo))
                        LOOP
                           t_recibo.EXTEND;
                           t_recibo (t_recibo.LAST) := ob_lista_id ();
                           t_recibo (t_recibo.LAST).idd := rec.nrecibo;
                        END LOOP;

                        vpasexec := 16;

                        IF t_recibo IS NOT NULL
                        THEN
                           IF t_recibo.COUNT > 0
                           THEN
                              vpasexec := 17;
                              vnumerr :=
                                 pac_gestion_rec.f_agruparecibo
                                                              (r0.sproduc,
                                                               r0.fefecto,
                                                               f_sysdate,
                                                               r0.cempres,
                                                               t_recibo,
                                                               tiprec.ctiprec
                                                              );

                              IF vnumerr <> 0
                              THEN
                                 mensajes := NULL;
                                 pac_iobj_mensajes.crea_nuevo_mensaje
                                                                   (mensajes,
                                                                    1,
                                                                    vnumerr
                                                                   );
                                 RAISE e_object_error;
                              END IF;

                              /* Si se han creado y unificado recibos, cambiamos el CMOTMOV*/
                              vpasexec := 18;

                              IF v_issuplem_0
                              THEN
                                 UPDATE movseguro
                                    SET cmotmov = 997
                                  WHERE sseguro = r0.sseguro
                                    AND nmovimi = v_mov;
                              END IF;

                              vpasexec := 19;

                              SELECT MAX (nrecibo)
                                INTO v_nrecunif
                                FROM recibos
                               WHERE sseguro = r0.sseguro
                                 AND nmovimi = v_mov
                                 AND ctiprec = tiprec.ctiprec;

                              IF v_sproces IS NOT NULL
                              THEN
                                 vpasexec := 21;
                                 v_nprolin := NULL;

                                 IF v_nrecunif IS NOT NULL
                                 THEN
                                    vnumerr :=
                                       f_proceslin
                                           (v_sproces,
                                               f_axis_literales (9904025,
                                                                 f_usu_idioma
                                                                )
                                            || '. '
                                            || f_axis_literales (102302,
                                                                 f_usu_idioma
                                                                )
                                            || ' = '
                                            || tiprec.ctiprec,
                                            v_nrecunif,
                                            v_nprolin,
                                            4
                                           );
                                 ELSE
                                    vnumerr :=
                                       f_proceslin
                                           (v_sproces,
                                               f_axis_literales (9901207,
                                                                 f_usu_idioma
                                                                )
                                            || '. '
                                            || f_axis_literales (102302,
                                                                 f_usu_idioma
                                                                )
                                            || ' = '
                                            || tiprec.ctiprec,
                                            -1,
                                            v_nprolin,
                                            1
                                           );
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                     END LOOP;
                  ELSE
                     /* Resto de recibos*/
                     FOR tiprec IN (SELECT DISTINCT r.ctiprec
                                               FROM recibos r,
                                                    detmovsegurocol d
                                              WHERE r.sseguro = d.sseguro_cert
                                                AND r.nmovimi = d.nmovimi_cert
                                                AND d.sseguro_0 = r0.sseguro
                                                AND d.nmovimi_0 = v_mov
                                                AND r.ctiprec NOT IN (13, 15)
                                                AND f_cestrec_mv (r.nrecibo,
                                                                  2) = 0
                                                AND NOT EXISTS (
                                                       SELECT a.nrecibo
                                                         FROM adm_recunif a
                                                        WHERE a.nrecibo =
                                                                     r.nrecibo)
                                    UNION
                                    SELECT DISTINCT r.ctiprec
                                               FROM recibos r
                                              WHERE r.sseguro = r0.sseguro
                                                AND r.nmovimi = v_mov
                                                AND r.ctiprec NOT IN (13, 15)
                                                AND f_cestrec_mv (r.nrecibo,
                                                                  2) = 0
                                                AND NOT EXISTS (
                                                       SELECT a.nrecibo
                                                         FROM adm_recunif a
                                                        WHERE a.nrecibo =
                                                                     r.nrecibo)
                                           ORDER BY ctiprec)
                     LOOP
                        v_array (tiprec.ctiprec) := NULL;
                        v_array (tiprec.ctiprec) := t_lista_id ();
                        vpasexec := 15;

                        FOR rec IN
                           (SELECT r.nrecibo
                              FROM recibos r, detmovsegurocol d
                             WHERE r.sseguro = d.sseguro_cert
                               AND r.nmovimi = d.nmovimi_cert
                               AND r.ctiprec = tiprec.ctiprec
                               AND d.sseguro_0 = r0.sseguro
                               AND d.nmovimi_0 = v_mov
                               AND f_cestrec_mv (r.nrecibo, 2) = 0
                               AND NOT EXISTS (SELECT a.nrecibo
                                                 FROM adm_recunif a
                                                WHERE a.nrecibo = r.nrecibo)
                            UNION
                            SELECT r.nrecibo
                              FROM recibos r
                             WHERE r.sseguro = r0.sseguro
                               AND r.nmovimi = v_mov
                               AND r.ctiprec = tiprec.ctiprec
                               AND f_cestrec_mv (r.nrecibo, 2) = 0
                               AND NOT EXISTS (SELECT a.nrecibo
                                                 FROM adm_recunif a
                                                WHERE a.nrecibo = r.nrecibo)
                               AND NOT EXISTS (SELECT a.nrecunif
                                                 FROM adm_recunif a
                                                WHERE a.nrecunif = r.nrecibo))
                        LOOP
                           v_array (tiprec.ctiprec).EXTEND;
                           v_array (tiprec.ctiprec)
                                                (v_array (tiprec.ctiprec).LAST
                                                ) := ob_lista_id ();
                           v_array (tiprec.ctiprec)
                                                 (v_array (tiprec.ctiprec).LAST
                                                 ).idd := rec.nrecibo;
                        END LOOP;
                     END LOOP;

                     vpasexec := 16;

                     IF v_array IS NOT NULL
                     THEN
                        v_totalp := 0;
                        v_totaln := 0;
                        t_recibo := NULL;
                        t_recibo := t_lista_id ();
                        vpasexec := 161;

                        /*------- Movimientos positivos ---------*/
                        /* Producción*/
                        IF v_array.EXISTS (0)
                        THEN
                           IF v_array (0).COUNT > 0
                           THEN
                              vpasexec := 162;

                              FOR i IN v_array (0).FIRST .. v_array (0).LAST
                              LOOP
                                 vpasexec := 163;

                                 BEGIN
                                    SELECT itotalr
                                      INTO v_total_pos
                                      FROM vdetrecibos
                                     WHERE nrecibo = v_array (0) (i).idd;

                                    v_totalp := v_totalp + v_total_pos;
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       NULL;
                                 END;

                                 t_recibo.EXTEND;
                                 t_recibo (t_recibo.LAST) := ob_lista_id ();
                                 t_recibo (t_recibo.LAST).idd :=
                                                           v_array (0) (i).idd;
                              END LOOP;
                           END IF;
                        END IF;

                        /*------- Movimientos positivos ---------*/
                        /* Recibos de cartera*/
                        IF v_array.EXISTS (3)
                        THEN
                           IF v_array (3).COUNT > 0
                           THEN
                              vpasexec := 162;

                              FOR i IN v_array (3).FIRST .. v_array (3).LAST
                              LOOP
                                 vpasexec := 163;

                                 BEGIN
                                    SELECT itotalr
                                      INTO v_total_pos
                                      FROM vdetrecibos
                                     WHERE nrecibo = v_array (3) (i).idd;

                                    v_totalp := v_totalp + v_total_pos;
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       NULL;
                                 END;

                                 t_recibo.EXTEND;
                                 t_recibo (t_recibo.LAST) := ob_lista_id ();
                                 t_recibo (t_recibo.LAST).idd :=
                                                           v_array (3) (i).idd;
                              END LOOP;
                           END IF;
                        END IF;

                        /* Suplementos*/
                        IF v_array.EXISTS (1)
                        THEN
                           IF v_array (1).COUNT > 0
                           THEN
                              vpasexec := 164;

                              FOR i IN v_array (1).FIRST .. v_array (1).LAST
                              LOOP
                                 vpasexec := 165;

                                 BEGIN
                                    SELECT itotalr
                                      INTO v_total_pos
                                      FROM vdetrecibos
                                     WHERE nrecibo = v_array (1) (i).idd;

                                    v_totalp := v_totalp + v_total_pos;
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       NULL;
                                 END;

                                 t_recibo.EXTEND;
                                 t_recibo (t_recibo.LAST) := ob_lista_id ();
                                 t_recibo (t_recibo.LAST).idd :=
                                                           v_array (1) (i).idd;
                              END LOOP;
                           END IF;
                        END IF;

                        /*------- Movimientos negativos ---------*/
                        /* extornos*/
                        IF v_array.EXISTS (9)
                        THEN
                           IF v_array (9).COUNT > 0
                           THEN
                              vpasexec := 170;

                              FOR i IN v_array (9).FIRST .. v_array (9).LAST
                              LOOP
                                 vpasexec := 171;

                                 BEGIN
                                    SELECT itotalr
                                      INTO v_total_neg
                                      FROM vdetrecibos
                                     WHERE nrecibo = v_array (9) (i).idd;

                                    v_totaln := v_totaln + v_total_neg;
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       NULL;
                                 END;

                                 t_recibo.EXTEND;
                                 t_recibo (t_recibo.LAST) := ob_lista_id ();
                                 t_recibo (t_recibo.LAST).idd :=
                                                           v_array (9) (i).idd;
                              END LOOP;
                           END IF;
                        END IF;

                        vpasexec := 172;

                        IF v_totalp >= v_totaln
                        THEN
                           v_tiprec := 1;
                        ELSE
                           v_tiprec := 9;
                        END IF;

                        IF t_recibo.COUNT > 0
                        THEN
                           vpasexec := 17;
                           vnumerr :=
                              pac_gestion_rec.f_agruparecibo (r0.sproduc,
                                                              r0.fefecto,
                                                              f_sysdate,
                                                              r0.cempres,
                                                              t_recibo,
                                                              v_tiprec,
                                                              1
                                                             );

                           IF vnumerr <> 0
                           THEN
                              mensajes := NULL;
                              pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                                    1,
                                                                    vnumerr
                                                                   );
                              RAISE e_object_error;
                           END IF;

                           /* Si se han creado y unificado recibos, cambiamos el CMOTMOV*/
                           vpasexec := 18;

                           IF v_issuplem_0
                           THEN
                              UPDATE movseguro
                                 SET cmotmov = 997
                               WHERE sseguro = r0.sseguro AND nmovimi = v_mov;
                           END IF;

                           vpasexec := 19;

                           SELECT MAX (nrecibo)
                             INTO v_nrecunif
                             FROM recibos
                            WHERE sseguro = r0.sseguro
                              AND nmovimi = v_mov
                              AND ctiprec = v_tiprec;

                           /* BUG 0026035 - 12/02/2013 - JMF  antes --BUG 23183-XVM-08/11/2012*/
                           IF v_nrecunif IS NOT NULL
                           THEN
                              vpasexec := 20;

                              UPDATE detrecibos
                                 SET iconcep = ABS (iconcep)
                               WHERE nrecibo = v_nrecunif;
                           END IF;

                           IF v_sproces IS NOT NULL
                           THEN
                              vpasexec := 21;
                              v_nprolin := NULL;

                              IF v_nrecunif IS NOT NULL
                              THEN
                                 vnumerr :=
                                    f_proceslin
                                           (v_sproces,
                                               f_axis_literales (9904025,
                                                                 f_usu_idioma
                                                                )
                                            || '. '
                                            || f_axis_literales (102302,
                                                                 f_usu_idioma
                                                                )
                                            || ' = '
                                            || v_tiprec,
                                            v_nrecunif,
                                            v_nprolin,
                                            4
                                           );
                              ELSE
                                 vnumerr :=
                                    f_proceslin
                                           (v_sproces,
                                               f_axis_literales (9901207,
                                                                 f_usu_idioma
                                                                )
                                            || '. '
                                            || f_axis_literales (102302,
                                                                 f_usu_idioma
                                                                )
                                            || ' = '
                                            || v_tiprec,
                                            -1,
                                            v_nprolin,
                                            1
                                           );
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  END IF;

                  /* Recibos de retorno*/
                  FOR tiprec IN (SELECT DISTINCT r.ctiprec
                                            FROM recibos r, detmovsegurocol d
                                           WHERE r.sseguro = d.sseguro_cert
                                             AND r.nmovimi = d.nmovimi_cert
                                             AND d.sseguro_0 = r0.sseguro
                                             AND d.nmovimi_0 = v_mov
                                             AND r.ctiprec IN (13, 15)
                                             AND f_cestrec_mv (r.nrecibo, 2) =
                                                                             0
                                             AND NOT EXISTS (
                                                    SELECT a.nrecibo
                                                      FROM adm_recunif a
                                                     WHERE a.nrecibo =
                                                                     r.nrecibo)
                                 UNION
                                 SELECT DISTINCT r.ctiprec
                                            FROM recibos r
                                           WHERE r.sseguro = r0.sseguro
                                             AND r.nmovimi = v_mov
                                             AND r.ctiprec IN (13, 15)
                                             AND f_cestrec_mv (r.nrecibo, 2) =
                                                                             0
                                             AND NOT EXISTS (
                                                    SELECT a.nrecibo
                                                      FROM adm_recunif a
                                                     WHERE a.nrecibo =
                                                                     r.nrecibo)
                                        ORDER BY ctiprec)
                  LOOP
                     t_recibo := NULL;
                     t_recibo := t_lista_id ();
                     vpasexec := 147;

                     FOR pers IN (SELECT DISTINCT r.sperson
                                             FROM recibos r,
                                                  detmovsegurocol d
                                            WHERE r.sseguro = d.sseguro_cert
                                              AND r.nmovimi = d.nmovimi_cert
                                              AND r.ctiprec = tiprec.ctiprec
                                              AND d.sseguro_0 = r0.sseguro
                                              AND d.nmovimi_0 = v_mov
                                              AND f_cestrec_mv (r.nrecibo, 2) =
                                                                             0
                                              AND NOT EXISTS (
                                                     SELECT a.nrecibo
                                                       FROM adm_recunif a
                                                      WHERE a.nrecibo =
                                                                     r.nrecibo)
                                  UNION
                                  SELECT DISTINCT r.sperson
                                             FROM recibos r
                                            WHERE r.sseguro = r0.sseguro
                                              AND r.nmovimi = v_mov
                                              AND r.ctiprec = tiprec.ctiprec
                                              AND f_cestrec_mv (r.nrecibo, 2) =
                                                                             0
                                              AND NOT EXISTS (
                                                     SELECT a.nrecibo
                                                       FROM adm_recunif a
                                                      WHERE a.nrecibo =
                                                                     r.nrecibo)
                                              AND NOT EXISTS (
                                                     SELECT a.nrecunif
                                                       FROM adm_recunif a
                                                      WHERE a.nrecunif =
                                                                     r.nrecibo))
                     LOOP
                        vpasexec := 15;

                        FOR rec IN
                           (SELECT r.nrecibo
                              FROM recibos r, detmovsegurocol d
                             WHERE r.sseguro = d.sseguro_cert
                               AND r.nmovimi = d.nmovimi_cert
                               AND r.ctiprec = tiprec.ctiprec
                               AND NVL (r.sperson, -1) = NVL (pers.sperson,
                                                              -1)
                               AND d.sseguro_0 = r0.sseguro
                               AND d.nmovimi_0 = v_mov
                               AND f_cestrec_mv (r.nrecibo, 2) = 0
                               AND NOT EXISTS (SELECT a.nrecibo
                                                 FROM adm_recunif a
                                                WHERE a.nrecibo = r.nrecibo)
                            UNION
                            SELECT r.nrecibo
                              FROM recibos r
                             WHERE r.sseguro = r0.sseguro
                               AND r.nmovimi = v_mov
                               AND r.ctiprec = tiprec.ctiprec
                               AND NVL (r.sperson, -1) = NVL (pers.sperson,
                                                              -1)
                               AND f_cestrec_mv (r.nrecibo, 2) = 0
                               AND NOT EXISTS (SELECT a.nrecibo
                                                 FROM adm_recunif a
                                                WHERE a.nrecibo = r.nrecibo)
                               AND NOT EXISTS (SELECT a.nrecunif
                                                 FROM adm_recunif a
                                                WHERE a.nrecunif = r.nrecibo))
                        LOOP
                           t_recibo.EXTEND;
                           t_recibo (t_recibo.LAST) := ob_lista_id ();
                           t_recibo (t_recibo.LAST).idd := rec.nrecibo;
                        END LOOP;

                        vpasexec := 16;

                        IF t_recibo IS NOT NULL
                        THEN
                           IF t_recibo.COUNT > 0
                           THEN
                              vpasexec := 17;
                              vnumerr :=
                                 pac_gestion_rec.f_agruparecibo
                                                              (r0.sproduc,
                                                               r0.fefecto,
                                                               f_sysdate,
                                                               r0.cempres,
                                                               t_recibo,
                                                               tiprec.ctiprec
                                                              );

                              IF vnumerr <> 0
                              THEN
                                 mensajes := NULL;
                                 pac_iobj_mensajes.crea_nuevo_mensaje
                                                                   (mensajes,
                                                                    1,
                                                                    vnumerr
                                                                   );
                                 RAISE e_object_error;
                              END IF;

                              /* Si se han creado y unificado recibos, cambiamos el CMOTMOV*/
                              vpasexec := 18;

                              IF v_issuplem_0
                              THEN
                                 UPDATE movseguro
                                    SET cmotmov = 997
                                  WHERE sseguro = r0.sseguro
                                    AND nmovimi = v_mov;
                              END IF;

                              vpasexec := 19;

                              SELECT MAX (nrecibo)
                                INTO v_nrecunif
                                FROM recibos
                               WHERE sseguro = r0.sseguro
                                 AND nmovimi = v_mov
                                 AND ctiprec = tiprec.ctiprec;

                              /* BUG 0026035 - 12/02/2013 - JMF  antes --BUG 23183-XVM-08/11/2012*/
                              IF v_nrecunif IS NOT NULL
                              THEN
                                 vpasexec := 20;

                                 UPDATE recibos
                                    SET sperson = pers.sperson
                                  WHERE nrecibo = v_nrecunif;
                              END IF;

                              IF v_sproces IS NOT NULL
                              THEN
                                 vpasexec := 21;
                                 v_nprolin := NULL;

                                 IF v_nrecunif IS NOT NULL
                                 THEN
                                    vnumerr :=
                                       f_proceslin
                                           (v_sproces,
                                               f_axis_literales (9904025,
                                                                 f_usu_idioma
                                                                )
                                            || '. '
                                            || f_axis_literales (102302,
                                                                 f_usu_idioma
                                                                )
                                            || ' = '
                                            || tiprec.ctiprec,
                                            v_nrecunif,
                                            v_nprolin,
                                            4
                                           );
                                 ELSE
                                    vnumerr :=
                                       f_proceslin
                                           (v_sproces,
                                               f_axis_literales (9901207,
                                                                 f_usu_idioma
                                                                )
                                            || '. '
                                            || f_axis_literales (102302,
                                                                 f_usu_idioma
                                                                )
                                            || ' = '
                                            || tiprec.ctiprec,
                                            -1,
                                            v_nprolin,
                                            1
                                           );
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                     END LOOP;
                  END LOOP;
               END IF;

               /* Bug 29665/163854 - 22/01/2014 - AMC*/
               UPDATE movseguro m
                  SET m.femisio = f_sysdate
                WHERE m.sseguro = psseguro AND m.nmovimi = v_mov;

               UPDATE seguros
                  SET csituac = 0,
                      nsuplem = v_nsuplem
                WHERE sseguro = psseguro;

               /* Fi Bug 29665/163854 - 22/01/2014 - AMC*/
               pac_iax_produccion.isaltacol := v_isaltacol;
               pcontinuaemitir := 0;
               /*Si se continua con la emision.*/
               vpasexec := 25;
               vnumerr := f_procesfin (v_sproces, 0);
               psproces := v_sproces;
            END IF;
         /*Fi Bug 29665/163095 - 14/01/2014 - AMC*/
         ELSE
            /* Bug 29358/161160 - 12/12/2013 - AMC*/
            IF v_bloq AND NOT v_entra
            THEN
               /* v_bloq = TRUE --> No hay ningún certificado con creteni = 2*/
               /* v_entra = FALSE --> No hay ningún certificado con creteni = 0*/
               /* Por tanto, entonces sÃ­ que tienes que borrar el movimiento.*/
               /* Bug 26151 - APD - 22/02/2013*/
               pcontinuaemitir := 1;
               /* No se continua con la emision.*/
               /* fin Bug 26151 - APD - 22/02/2013*/
               vpasexec := 22;

               UPDATE seguros
                  SET csituac = 0
                WHERE sseguro = r0.sseguro;

               vpasexec := 23;

               /* Bug 26151 - APD - 22/02/2013 - se debe eliminar tambien el movimiento anterior en historicoseguros*/
               DELETE FROM historicoseguros
                     WHERE sseguro = r0.sseguro
                       AND nmovimi =
                              (SELECT MAX (nmovimi)
                                 FROM movseguro
                                WHERE sseguro = r0.sseguro
                                  AND nmovimi < v_mov
                                  AND cmovseg <> 52);

               /* no anulado*/
               /* fin Bug 26151 - APD - 22/02/2013*/
               /* Bug 28263 - FPG - 18-11-2013 - Inicio - Borrar la asociación con el caso BPM*/
               vpasexec := 231;

               DELETE      casos_bpmseg
                     WHERE sseguro = r0.sseguro AND nmovimi = v_mov;

               /* Bug 28263 - FPG - 18-11-2013  - Fin*/
               vpasexec := 24;

               /*INI Bug 39530-KJSC-08/03/2016 Esta generando error '-2292-ORA-02292: integrity constraint (AXIS.RECIBOS_MOVSEGURO_FK) violated - child record found'*/
               /*al tratar de borrar el movseguro cuando se rehabilita los certificados-.*/
               SELECT COUNT (1)
                 INTO numrecibos
                 FROM recibos
                WHERE sseguro = r0.sseguro AND nmovimi = v_mov;

               IF numrecibos = 0
               THEN
                  DELETE      movseguro
                        WHERE sseguro = r0.sseguro AND nmovimi = v_mov;
               END IF;
            /*FIN Bug 39530-KJSC-08/03/2016*/
            END IF;
         /* Fi Bug 29358/161160 - 12/12/2013 - AMC*/
         END IF;
      END LOOP;

      vpasexec := 25;
      vnumerr := f_procesfin (v_sproces, 0);
      psproces := v_sproces;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         /*BUG27048/150505 - DCT - 05/08/2013 - Inicio -*/
         /*pac_seguros.p_modificar_seguro(psseguro, v_creteni);*/
         /*BUG27048/150505 - DCT - 05/08/2013 - Fin -*/
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         /*BUG27048/150505 - DCT - 05/08/2013 - Inicio -*/
         /*pac_seguros.p_modificar_seguro(psseguro, v_creteni);*/
         /*BUG27048/150505 - DCT - 05/08/2013 - Fin -*/
         pac_iax_produccion.isaltacol := v_isaltacol;

         IF v_sproces IS NOT NULL
         THEN
            v_nprolin := NULL;
            vnumerr :=
               f_proceslin (v_sproces,
                               f_axis_literales (140730, f_usu_idioma)
                            || ': '
                            || onpoliza
                            || '-'
                            || oncertif
                            || '. Error: '
                            || f_axis_literales (vnumerr, f_usu_idioma),
                            v_sseguro,
                            v_nprolin,
                            1
                           );
            vnumerr := f_procesfin (v_sproces, vnumerr);
         END IF;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF v_botonemite
         THEN
            RETURN -1;
         ELSE
            RETURN 1;
         END IF;
      WHEN OTHERS
      THEN
         /*BUG27048/150505 - DCT - 05/08/2013 - Inicio -*/
         /*pac_seguros.p_modificar_seguro(psseguro, v_creteni);*/
         /*BUG27048/150505 - DCT - 05/08/2013 - Fin -*/
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_MD_PRODUCCION.f_emitir_col_admin',
                      '1',
                      '1',
                         'vpasexec = '
                      || vpasexec
                      || ' '
                      || SQLCODE
                      || ' - '
                      || SQLERRM
                     );
         mensajes := NULL;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, SQLCODE, SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_emitir_col_admin;

   /* Bug 24278 - APD - 05/12/2012 - se a?? el parametro pfecha*/
   FUNCTION f_abrir_suplemento (
      psseguro   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobjectname     VARCHAR2 (100)
                                    := 'PAC_MD_PRODUCCION.f_abrir_suplemento';
      vparam          VARCHAR2 (2000)
                                     := 'parametros - psseguro: ' || psseguro;
      vnumerr         NUMBER;
      vpasexec        NUMBER          := 0;
      v_mov           NUMBER;
      v_mov_ant       NUMBER;
      v_max_nsuplem   NUMBER;                            /* 0029665/0166164*/

      CURSOR c_cert0
      IS
         SELECT sseguro, csituac, creteni, npoliza, ncertif, fefecto,
                cempres, sproduc, nsuplem, fcarpro
           FROM seguros
          WHERE sseguro = psseguro AND csituac = 0 AND creteni = 0;
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      /*BUG 29229 - INICIO - DCT - 09/12/2013 - LCOL_T010-LCOL - Revision incidencias Suspensión / Reinicio (VIII)*/
      /*IF pac_seguros.f_suspendida(psseguro, f_sysdate) = 1 THEN*/
      /*   mensajes := NULL;*/
      /*   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904861);*/
      /*   RAISE e_object_error;*/
      /*ELSE*/
      FOR r0 IN c_cert0
      LOOP
         /* 0029665/0166164 - INI*/
         BEGIN
            SELECT MAX (nsuplem)
              INTO v_max_nsuplem
              FROM movseguro
             WHERE sseguro = r0.sseguro AND cmovseg <> 52;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_max_nsuplem := r0.nsuplem;
         END;

         /* 0029665/0166164 - FIN*/
         vpasexec := 2;
         vnumerr :=
            f_movseguro
               (r0.sseguro,
                NULL,
                996,
                1,
                LEAST
                   (GREATEST
                       (pac_movseguro.f_get_fefecto
                                   (r0.sseguro,
                                    pac_movseguro.f_nmovimi_valido (r0.sseguro)
                                   ),
                        f_sysdate
                       ),
                    NVL (r0.fcarpro, f_sysdate)
                   ),
                NULL,
                /*r0.nsuplem + 1,*/
                /* 0029665/0166164*/
                v_max_nsuplem + 1,
                0,
                NULL,
                v_mov,
                NULL,
                NULL,
                998
               );

         IF vnumerr <> 0
         THEN
            mensajes := NULL;
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 3;

         /* Bug 26151 - APD - 22/02/2013 - se guarda el historico del movimiento anterior*/
         SELECT MAX (nmovimi)
           INTO v_mov_ant
           FROM movseguro
          WHERE sseguro = r0.sseguro AND nmovimi < v_mov AND cmovseg <> 52;

         /* no anulado*/
         vnumerr := f_act_hisseg (r0.sseguro, v_mov_ant);

         IF vnumerr <> 0
         THEN
            mensajes := NULL;
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 4;

         /* fin Bug 26151 - APD - 22/02/2013*/
         UPDATE seguros
            SET csituac = 5
          WHERE sseguro = r0.sseguro;
      END LOOP;

      /*END IF;*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_abrir_suplemento;

   /* BUG22839:DRA:26/09/2012:Fi*/
   /* BUG22839:DRA:26/09/2012:Fi*/
   /* Ini Bug 22839 - MDS - 30/10/2012*/
   /*************************************************************************
      Recupera la cuenta corriente del tomador del certificado 0
      param in psperson  : cdigo persona
      param in pnpoliza  : nmero pliza
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tomadorccc_certif0 (
      psperson   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes,
      pnpoliza   IN       NUMBER,
      pmandato   IN       VARCHAR2 DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (1)    := NULL;
      vobject    VARCHAR2 (200)
                              := 'PAC_MD_PRODUCCION.F_Get_TomadorCCC_certif0';
      squery     VARCHAR2 (3000);
      cur        sys_refcursor;
   BEGIN
      squery :=
            'SELECT sperson, cbancar, Tcbancar, ctipban, snip, cbancar_1, cdefecto FROM  ( '
         || 'SELECT t.SPERSON, s.CBANCAR,
                              PAC_MD_COMMON.F_FormatCCC(s.CTIPBAN,s.CBANCAR) Tcbancar, s.CTIPBAN,
                              PS.SNIP,s.CBANCAR cbancar_1,
                              (select cdefecto
                               from per_ccc p
                               where p.sperson = PS.SPERSON
                                 and p.cbancar = s.cbancar
                                 and p.cagente = ps.cagente
                                 and p.ctipban = ps.ctipban) cdefecto
                              FROM TOMADORES t , PERSONAS PS, SEGUROS s
                              WHERE t.SPERSON = PS.SPERSON
                              AND t.sseguro = s.sseguro
                              AND s.sseguro = (select sseguro from seguros where ncertif = 0 and npoliza ='
         || pnpoliza
         || ') ) sel ';

      /* RSA MANDATOS*/
      IF NVL (pmandato, 'N') = 'S'
      THEN
         squery :=
               squery
            || ' WHERE EXISTS (SELECT 1 from  MANDATOS MA
                                          WHERE MA.CBANCAR = sel.cbancar
                                          AND MA.SPERSON = sel.sperson
                                          AND  ma.cestado IN (0,1))';
      END IF;

      squery := squery || ' ORDER BY CDEFECTO DESC';
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tomadorccc_certif0;

   /* Fin Bug 22839 - MDS - 30/10/2012*/
   /* Bug 26070:- ECP - 28/02/2013 - se crea la funcion f_get_efectocol*/
   /***************************************************************************
      FUNCTION f_get_efectocol
      Dado un numero de poliza, obtenemos fecha efecto de su certificado 0
         param in  pnpoliza:  numero de la póliza.
         return:              DATE
   ***************************************************************************/
   FUNCTION f_get_efectocol (pnpoliza IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN DATE
   IS
      vparam      VARCHAR2 (200);
      vpasexec    NUMBER (8)             := 1;
      vobject     VARCHAR2 (200)       := 'PAC_MD_PRODUCCION.f_get_efectocol';
      v_fefecto   seguros.fefecto%TYPE;
   BEGIN
      SELECT fefecto
        INTO v_fefecto
        FROM seguros
       WHERE npoliza = pnpoliza AND ncertif = 0;

      RETURN v_fefecto;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_efectocol;

   /* Fin Bug 26070:- ECP - 28/02/2013*/
   /***************************************************************************
   -- Bug 27923 - INICIO - DCT - 06/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado
         Indica si la garantÃ­a se encuentra contratada o no en el certificado 0 y si lo está devolver la respuesta de la pregunta
         "Obligatorio / Opcional" ( cpregun = 9094)
         return: NUMBER (
      ***************************************************************************/
   FUNCTION f_get_obligaopcional_cero (
      pnpoliza   IN       NUMBER,
      pplan      IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam      VARCHAR2 (200);
      vpasexec    NUMBER (8)                    := 1;
      vobject     VARCHAR2 (200)
                             := 'PAC_MD_PRODUCCION.f_get_obligaopcional_cero';
      vconta      NUMBER;
      vpreg9094   pregungaranseg.crespue%TYPE;
      vsseguro    seguros.sseguro%TYPE;
      /*BUG0027923 - INICIO - DCT - 21/10/2013  -LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
      vsproduc    seguros.sproduc%TYPE;
      v_cvalpar   NUMBER;
      vnumerr     NUMBER;
   /*BUG0027923 - FIN - DCT - 21/10/2013  -LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
   BEGIN
      SELECT COUNT (*)
        INTO vconta
        FROM garanseg g, seguros s, riesgos r
       WHERE g.sseguro = s.sseguro
         AND g.ffinefe IS NULL
         AND g.nriesgo = r.nriesgo
         AND s.sseguro = r.sseguro
         AND r.nriesgo = NVL (pplan, r.nriesgo)
         AND s.npoliza = pnpoliza
         AND s.ncertif = 0
         AND g.cgarant = pcgarant;

      IF vconta > 0
      THEN
         /*BUG0027923 - INICIO - DCT - 21/10/2013  -LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
         /* Obtener el sseguro del certificado 0*/
         SELECT sseguro, sproduc
           INTO vsseguro, vsproduc
           FROM seguros
          WHERE npoliza = pnpoliza AND ncertif = 0;

         /*BUG0027923 - FIN - DCT - 21/10/2013  -LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
         /*BUG0027923 - INICIO - DCT - 21/10/2013  -LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
         v_cvalpar :=
            NVL (pac_parametros.f_parproducto_n (vsproduc, 'HEREDA_GARANTIAS'),
                 0
                );
         /*BUG0027923 - FIN - DCT - 21/10/2013  -LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
         /*BUG0027923 - INICIO - DCT - 21/10/2013  -LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
         /*IF v_cvalpar = 4 THEN*/
         /* Obtener pregunta 'Obligatorio / Opcional' del certificado 0:*/
         vpreg9094 :=
            pac_preguntas.f_get_pregungaranseg_v (vsseguro,
                                                  pcgarant,
                                                  NVL (pplan, 1),
                                                  9094,
                                                  'SEG'
                                                 );

         /* Si la pregunta es diferente de NULL*/
         IF vpreg9094 IS NOT NULL
         THEN
            RETURN vpreg9094;
         ELSE
            RETURN 0;
         END IF;
      /*ELSE
       vnumerr := pac_preguntas.f_get_pregungaranseg(vsseguro, pcgarant, NVL(pplan, 1),
                                                     9094, 'SEG', vpreg9094);

       IF vnumerr = 120135 THEN
          RETURN vnumerr;
       ELSIF vnumerr IN (0, 1) THEN
          RETURN vpreg9094;
       ELSE
          RETURN NULL;
       END IF;
      END IF;*/
      /*BUG0027923 - FIN - DCT - 21/10/2013  -LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado 0*/
      ELSE
         RETURN -1;                      /* la garantÃ­a NO está contratada*/
      END IF;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_get_obligaopcional_cero;

   /* Bug 27923 - FIN - DCT - 06/09/2013 - LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definici?n de condiciones en Certificado*/
   /* Bug 29665/163095 - 13/01/2014 - AMC*/
   FUNCTION f_lanzajob_emitecol_admin (
      psseguro          IN   NUMBER,
      psproces          IN   NUMBER,
      pcontinuaemitir   IN   NUMBER,
      ppasapsu          IN   NUMBER DEFAULT 1,
      pskipfusion       IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      vparam             VARCHAR2 (500)
         :=    'psseguro:'
            || psseguro
            || ' psproces:'
            || psproces
            || ' pcontinuaemitir:'
            || pcontinuaemitir
            || ' ppasapsu:'
            || ppasapsu
            || ' pskipfusion:'
            || pskipfusion;
      vpasexec           NUMBER (8)                   := 1;
      vobjectname        VARCHAR2 (200)
                              := 'PAC_MD_PRODUCCION.f_lanzajob_emitecol_admin';
      mensajes           t_iax_mensajes;

      /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificación cursor)*/
      CURSOR c_certn (
         pc_npoliza   IN   NUMBER,
         p_fecha      IN   DATE,
         pc_creteni   IN   NUMBER
      )
      IS
         SELECT sseguro, csituac, creteni, npoliza, ncertif
           FROM seguros
          WHERE npoliza = pc_npoliza
            AND ncertif <> 0
            AND (   csituac IN (4, 5)
                 OR (    csituac = 2
                     AND EXISTS (
                            SELECT 1
                              FROM movseguro
                             WHERE sseguro = seguros.sseguro
                               AND cmovseg = 3
                               AND fmovimi >= p_fecha
                               /* Bug 26151 - APD - 01/03/2013*/
                               AND nmovimi NOT IN (
                                      SELECT nmovimi_cert
                                        FROM detmovsegurocol
                                       WHERE sseguro_0 = psseguro
                                         AND sseguro_cert = seguros.sseguro)
                                                                            /* fin Bug 26151 - APD - 01/03/2013*/
                         )
                    )
                )
            AND (   (creteni = 0 AND pc_creteni = 0)
                 OR (creteni = creteni AND pc_creteni <> 0)
                );

      /* Bug 26151 - APD - 07/03/2013*/
      vcsituac           NUMBER;
      vcreteni           NUMBER;
      vnpoliza           NUMBER;
      vncertif           NUMBER;
      vfefecto           DATE;
      vcempres           NUMBER;
      vsproduc           NUMBER;
      vnsuplem           NUMBER;
      vmoneda            NUMBER;
      onpoliza           NUMBER;
      oncertif           NUMBER;
      v_sseguro          NUMBER;
      v_issuplem         BOOLEAN;
      v_commit           NUMBER;
      v_mov              NUMBER;
      v_mov_n            NUMBER;
      v_cmotmov          NUMBER (3);
      v_fecha            DATE;
      vnumerr            NUMBER;
      v_sproces          NUMBER;
      v_nprolin          NUMBER (6);
      v_mov_aux          NUMBER;
      v_total_pos        NUMBER;
      v_total_neg        NUMBER;
      v_totalp           NUMBER;
      v_totaln           NUMBER;
      v_tiprec           NUMBER;
      v_resp_4821        NUMBER;
      v_primin_gen       NUMBER;
      v_generadorec      NUMBER;
      v_valor            NUMBER;
      v_numcert          NUMBER;
      v_ffefecto         DATE;
      v_fvencim          DATE;
      v_femisio          DATE;
      v_numrec           NUMBER;
      vcagastexp         seguroscol.cagastexp%TYPE    := 0;
      vcperiogast        seguroscol.cperiogast%TYPE   := 0;
      viimporgast        seguroscol.iimporgast%TYPE   := 0;
      vcforpag           seguros.cforpag%TYPE;
      v_fcaranu          DATE;
      v_fefecto          DATE;
      v_frenova          DATE;
      v_ctipcoa          seguros.ctipcoa%TYPE;
      xnfracci           recibos.nfracci%TYPE;
      xnanuali           recibos.nanuali%TYPE;
      v_cuotas           NUMBER;
      t_recibo           t_lista_id                   := t_lista_id ();
      v_issuplem_0       BOOLEAN;
      v_nrecunif         NUMBER;
      vcestadocol        movseguro.cestadocol%TYPE;
      vnmovimi           NUMBER;
      vcontinuaemitir    NUMBER                       := pcontinuaemitir;
      vt_iax_impresion   t_iax_impresion;

      TYPE data_t IS TABLE OF t_lista_id
         INDEX BY PLS_INTEGER;

      v_array            data_t;
      v_registro         NUMBER                       := 1;
   BEGIN
      v_sproces := psproces;

      SELECT csituac, creteni, npoliza, ncertif, fefecto, cempres,
             sproduc, nsuplem, pac_monedas.f_moneda_producto (sproduc) moneda
        INTO vcsituac, vcreteni, vnpoliza, vncertif, vfefecto, vcempres,
             vsproduc, vnsuplem, vmoneda
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT NVL (MAX (nmovimi), 1)
        INTO v_mov
        FROM movseguro
       WHERE sseguro = psseguro;

      /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias*/
      BEGIN
         SELECT m.fmovimi
           INTO v_fecha
           FROM seguros s, movseguro m
          WHERE s.npoliza = vnpoliza
            AND s.ncertif = 0
            AND s.sseguro = m.sseguro
            AND m.cmotmov = 996
            AND m.cmotven = 998
            AND m.nmovimi =
                   (SELECT MAX (m2.nmovimi)
                      FROM movseguro m2
                     WHERE m2.sseguro = m.sseguro
                       AND m2.cmotmov = m.cmotmov
                       AND m2.cmotven = 998);
      /* de abrir suplemento*/
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT m.fefecto
                 INTO v_fecha
                 FROM seguros s, movseguro m
                WHERE s.npoliza = vnpoliza
                  AND s.ncertif = 0
                  AND s.sseguro = m.sseguro
                  AND m.cmotmov = 100;
            /* de alta de colectivo (cobro anticipado)*/
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_fecha := f_sysdate;
            END;
      END;

      /* Bug 30842/0172239 -- APD - 08/04/2014 - las variables vnsuplem y v_issuplem_0 se deben comportar*/
      /* igual que en la funcion PAC_MD_PRODUCCION.f_emitir_col_admin.*/
      IF vcsituac = 5
      THEN
         vnsuplem := vnsuplem + 1;
         v_issuplem_0 := TRUE;
      ELSE
         vnsuplem := vnsuplem;
         v_issuplem_0 := FALSE;
      END IF;

      /* fin Bug 30842/0172239 -- APD - 08/04/2014*/
      FOR rn IN c_certn (vnpoliza, v_fecha, 0)
      LOOP
         vpasexec := 6;
         onpoliza := rn.npoliza;
         oncertif := rn.ncertif;
         v_sseguro := rn.sseguro;
         vpasexec := 7;

         SELECT NVL (MAX (nmovimi), 1)
           INTO v_mov_n
           FROM movseguro
          WHERE sseguro = rn.sseguro;

         IF rn.csituac = 5
         THEN
            v_issuplem := TRUE;
         ELSE
            v_issuplem := FALSE;
         END IF;

         /* Bug 23940 - APD - 15/11/2012 - si la poliza est?n*/
         /* csituac = 4.-Prop. Alta, por defecto, se debe dar*/
         /* de alta el colectivo como bloqueado*/
         /*
         IF rn.csituac = 4 THEN
         vnumerr := pac_propio.f_act_cbloqueocol(rn.sseguro);
         END IF;*/
         /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias*/
         IF rn.csituac IN (4, 5)
         THEN
            /* Fin Bug 26070*/
            /* fin Bug 23940 - APD - 15/11/2012*/
            vpasexec := 8;
            v_commit := 0;
            vnumerr :=
               pac_md_produccion.f_emitir (rn.sseguro,
                                           v_mov_n,
                                           v_issuplem,
                                           onpoliza,
                                           mensajes,
                                           v_sproces,
                                           v_commit
                                          );

            /* Bug 26070 -- ECP-- 21/02/2013*/
            IF vnumerr <> 0
            THEN
               /*mensajes := NULL;*/
               /*pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);*/
               IF mensajes IS NOT NULL
               THEN
                  IF mensajes.COUNT > 0
                  THEN
                     /* Puede que la emisin de los n-certificados d error y este no lo devuelve, pero queda*/
                     /*  almacenado en mensajes*/
                     /*mensajes := NULL;*/
                     pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            9900724,
                               f_axis_literales (140730,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || f_axis_literales (9900724,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ' '
                            || v_sproces
                           );
                  END IF;
               END IF;

               RAISE e_object_error;
            END IF;
         /* Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias*/
         END IF;

         /* Fin bug 26070*/
         vpasexec := 9;

         BEGIN
            INSERT INTO detmovsegurocol
                        (sseguro_0, nmovimi_0, sseguro_cert, nmovimi_cert
                        )
                 VALUES (psseguro, v_mov, rn.sseguro, v_mov_n
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobjectname,
                            vpasexec,
                            vparam,
                            ' err=' || SQLCODE || ' ' || SQLERRM
                           );
         END;

         vpasexec := 10;

         SELECT npoliza, ncertif
           INTO onpoliza, oncertif
           FROM seguros
          WHERE sseguro = rn.sseguro;

         vpasexec := 101;

         SELECT cmotmov
           INTO v_cmotmov
           FROM movseguro
          WHERE sseguro = rn.sseguro AND nmovimi = v_mov_n;

         vpasexec := 11;

         BEGIN
            INSERT INTO detmovseguro
                        (sseguro, nmovimi, cmotmov, nriesgo, cgarant,
                         cpregun, tvalora,
                         tvalord
                        )
                 VALUES (psseguro, v_mov, v_cmotmov, 0, 0,
                         0, NULL,
                         /* f_axis_literales(103289, pac_md_common.f_get_cxtidioma),*/
                         SUBSTR (onpoliza || '-' || oncertif, 1, 1000)
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               UPDATE detmovseguro
                  SET tvalord =
                         SUBSTR (tvalord || '; ' || onpoliza || '-'
                                 || oncertif,
                                 1,
                                 1000
                                )
                WHERE sseguro = psseguro
                  AND nmovimi = v_mov
                  AND cmotmov = v_cmotmov
                  AND nriesgo = 0
                  AND cgarant = 0
                  AND cpregun = 0;
         END;

         IF v_sproces IS NOT NULL
         THEN
            vpasexec := 12;
            v_nprolin := NULL;
            vnumerr :=
               f_proceslin (v_sproces,
                               f_axis_literales (151301, f_usu_idioma)
                            || ' '
                            || onpoliza
                            || '-'
                            || oncertif,
                            v_sseguro,
                            v_nprolin,
                            4
                           );
         END IF;

         FOR i IN (SELECT   s.sseguro, s.cidioma,
                            pac_isqlfor.f_max_nmovimi (s.sseguro) nmovimi,
                            ppc.ctipo
                       FROM prod_plant_cab ppc, seguros s
                      WHERE s.sseguro = rn.sseguro
                        AND s.sproduc = ppc.sproduc
                        AND ppc.ctipo = 41
                   GROUP BY s.sseguro, s.cidioma, ppc.ctipo)
         LOOP
            pac_isql.p_ins_doc_diferida (i.sseguro,
                                         i.nmovimi,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         i.cidioma,
                                         i.ctipo
                                        );
         END LOOP;

         COMMIT;
         v_registro := v_registro + 1;
      END LOOP;

      COMMIT;
      vpasexec := 13;

      SELECT MAX (nmovimi)
        INTO v_mov_aux
        FROM garanseg g
       WHERE sseguro = psseguro AND nriesgo = 1 AND ffinefe IS NULL;

      /*24058:DCT:08/11/2012:Inici*/
      vnumerr :=
         pac_tarifas.f_tarifar_riesgo_tot (NULL,
                                           psseguro,
                                           1,
                                           NVL (v_mov_aux, 1),
                                           vmoneda,
                                           vfefecto
                                          );

      IF vnumerr <> 0
      THEN
         mensajes := NULL;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      /*24058:DCT:08/11/2012:Fin*/
      /* Valor prima mÃ­nima del certificat 0*/
      vnumerr :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4821, 'SEG', v_resp_4821);
      vpasexec := 131;

      /* Bug 25583 - RSC - 29/01/2013*/
      SELECT COUNT (1)
        INTO v_primin_gen
        FROM recibos r, detrecibos d
       WHERE r.sseguro = psseguro
         AND d.nrecibo = r.nrecibo
         AND r.ctiprec = 0
         AND r.ctiprec = 0
         AND d.cgarant = 400
         AND d.cconcep = 0
         AND d.iconcep <> 0;

      /* BUG 0026341 - 12/03/2013 - JMF*/
      SELECT COUNT (1)
        INTO v_generadorec
        FROM recibos r, detmovsegurocol d
       WHERE r.sseguro = d.sseguro_cert
         AND r.nmovimi = d.nmovimi_cert
         AND d.sseguro_0 = psseguro
         AND d.nmovimi_0 = v_mov
         AND NOT EXISTS (SELECT a.nrecibo
                           FROM adm_recunif a
                          WHERE a.nrecibo = r.nrecibo);

      /* Ini 26488 -- ECP -- 19/03/2013*/
      IF v_primin_gen = 0 AND v_mov <= 2
      THEN
         /* La emisi??olectivo solo genera recibo de prima m?ma la primera vez. El resto de veces ya lo monta*/
         /* la cartera. Por eso podemos ir a vdetrecibos e ir a buscar el importe de recibos generados.*/
         /* Fin 26488 -- ECP -- 19/03/2013*/
         SELECT SUM (v.itotalr)
           INTO v_valor
           FROM detmovsegurocol d, recibos r, vdetrecibos v
          WHERE d.sseguro_0 = psseguro
            AND d.nmovimi_0 = v_mov
            AND d.sseguro_cert = r.sseguro
            AND d.nmovimi_cert = r.nmovimi
            AND r.ctiprec = 0
            AND r.nrecibo = v.nrecibo;

         /* Fin Bug 25583*/
         vpasexec := 132;

         /*Ini Bug 25583 -- ECP -- 24/01/2013*/
         IF NVL (v_valor, 0) < NVL (v_resp_4821, 0)
         THEN
            /* Miramos si se han generado recibos en el movimiento*/
            SELECT COUNT (d.sseguro_cert)
              INTO v_numcert
              FROM detmovsegurocol d
             WHERE d.sseguro_0 = psseguro AND d.nmovimi_0 = v_mov;

            /* Bug 25583 - ECP - 24/01/2013 Se agrega al IF AND v_numrec > 0 para controlar si existen recibo generados*/
            /* BUG 0026341 - 12/03/2013 - JMF: canvi v_numrec per v_generadorec*/
            IF v_numcert > 0 AND v_generadorec > 0
            THEN
               /* Bug 23853 - RSC - 17/12/201*/
               /*   v_ffefecto := GREATEST(r0.fefecto, f_sysdate);*/
               /* Fin bug 23853*/
               SELECT MIN (r.fefecto), MAX (r.fvencim), MAX (r.femisio)
                 INTO v_ffefecto, v_fvencim, v_femisio
                 FROM recibos r, detmovsegurocol d
                WHERE d.sseguro_0 = psseguro
                  AND d.nmovimi_0 = v_mov
                  AND r.sseguro = d.sseguro_cert
                  AND r.nmovimi = d.nmovimi_cert
                  AND NOT EXISTS (SELECT a.nrecibo
                                    FROM adm_recunif a
                                   WHERE a.nrecibo = r.nrecibo);

               vnumerr :=
                  pac_md_gestion_rec.f_genrec_primin_col (psseguro,
                                                          v_mov,
                                                          0,
                                                          v_femisio,
                                                          v_ffefecto,
                                                          v_fvencim,
                                                            NVL (v_resp_4821,
                                                                 0
                                                                )
                                                          - NVL (v_valor, 0),
                                                          v_numrec,
                                                          'R',
                                                          v_sproces,
                                                          'SEG',
                                                          mensajes
                                                         );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      END IF;

      vpasexec := 14;

      /* JLB - I - 23074 Creamos recibo de gastos de emision*/
      /*Colectivo individualizado + Colectivo multiple*/
      BEGIN
         SELECT cagastexp, cperiogast, iimporgast, cforpag, fcaranu,
                fefecto, frenova
           INTO vcagastexp, vcperiogast, viimporgast, vcforpag, v_fcaranu,
                v_fefecto, v_frenova
           FROM seguroscol sc, seguros seg
          WHERE seg.sseguro = psseguro AND sc.sseguro = seg.sseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            vcagastexp := 0;
            vcperiogast := 0;
            viimporgast := 0;
      END;

      /*            IF vcagastexp = 0 OR (xctiprec NOT IN(0, 3)) THEN*/
      /* solo aplico gastos en nuevaproduccio y carteras*/
      /*or nvl(xnanuali,1)>1  -- revisar si pnmovima = 1 Ã‚Â¿? ponemos la anualidad = 1*/
      /*             RETURN 1;   -- no aplica  gastos de expedicion*/
      /*         END IF;*/
      vpasexec := 141;

      /* Bug 23853 - RSC - 17/12/201*/
      /*v_ffefecto := GREATEST(r0.fefecto, f_sysdate);*/
      /* Fin bug 23853*/
      SELECT MIN (r.fefecto), MAX (r.fvencim), MAX (r.femisio)
        INTO v_ffefecto, v_fvencim, v_femisio
        FROM recibos r, detmovsegurocol d
       WHERE d.sseguro_0 = psseguro
         AND d.nmovimi_0 = v_mov
         AND r.sseguro = d.sseguro_cert
         AND r.nmovimi = d.nmovimi_cert
         AND NOT EXISTS (SELECT a.nrecibo
                           FROM adm_recunif a
                          WHERE a.nrecibo = r.nrecibo);

      vpasexec := 142;

      SELECT COUNT (d.sseguro_cert)
        INTO v_numcert
        FROM detmovsegurocol d
       WHERE d.sseguro_0 = psseguro AND d.nmovimi_0 = v_mov;

      vpasexec := 143;

      /* BUG 0026070 - 05/03/2013 - JMF*/
      /* Si tiene Coaseguro Aceptado no genera gastos expedición*/
      SELECT NVL (MAX (ctipcoa), 0)
        INTO v_ctipcoa
        FROM seguros
       WHERE sseguro = psseguro;

      /* Bug 25583 - ECP - 24/01/2013 Se agrega al IF AND v_numrec > 0 para controlar si existen recibo generados*/
      /* BUG 0026341 - 12/03/2013 - JMF: canvi v_numrec per v_generadorec*/
      IF v_numcert > 0 AND v_generadorec > 0 AND v_ctipcoa <> 8
      THEN
         IF vcagastexp = 1
         THEN
            /* de momento es 0 and tiprec.ctiprec in (0,3) THEN*/
            /* si aplica gastos en recibo agrupado y certificado en = 0 y tipo recibo NP o CATEREA*/
            IF (vcperiogast = 2 AND xnfracci > 0)
            THEN
               /* Si fraccionamiento es anual, y la fraccion no es la primera*/
               /* si el fraccionamiento es anual y la fracción no es la primera*/
               /* RETURN 1;*/
               NULL;
            ELSE
               IF vcperiogast = 2
               THEN
                  /* anual*/
                  /*viimporgast := viimporgast;*/
                  NULL;
               ELSIF vcperiogast = 1
               THEN
                  /* segun forma de pago*/
                  SELECT CEIL
                            (  MONTHS_BETWEEN
                                            (NVL (v_fcaranu,
                                                  NVL (v_frenova,
                                                       ADD_MONTHS (v_fefecto,
                                                                   12
                                                                  )
                                                      )
                                                 ),
                                             v_fefecto
                                            )
                             / vtramo (-1, 291, vcforpag)
                            )
                    INTO v_cuotas
                    FROM DUAL;

                  viimporgast := viimporgast / v_cuotas;
               END IF;

               vpasexec := 144;
               /* fraccionamiento anual*/
               vnumerr :=
                  pac_md_gestion_rec.f_genrec_gastos_expedicion (psseguro,
                                                                 v_mov,
                                                                 0,
                                                                 v_femisio,
                                                                 v_ffefecto,
                                                                 v_fvencim,
                                                                 viimporgast,
                                                                 v_numrec,
                                                                 'R',
                                                                 v_sproces,
                                                                 'SEG',
                                                                 mensajes
                                                                );

               IF vnumerr <> 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      END IF;

      vpasexec := 145;

      /*BUG27048/150505 - DCT - 05/08/2013 - Inicio -*/
      /*pac_seguros.p_modificar_seguro(psseguro, v_creteni);*/
      /*BUG27048/150505 - DCT - 05/08/2013 - Fin -*/
      /* deberia comprobar que sol o exista una garantia con derechos de registro?*/
      /* JLB - F  23074 Creamos recibo de gastos de emision*/
      /* Bug 25583 - ECP - 24/01/2013 Se agrega al IF AND v_numrec > 0 para controlar si existen recibo generados*/
      /* BUG 0026341 - 12/03/2013 - JMF: canvi v_numrec per v_generadorec*/
      IF v_generadorec > 0
      THEN
         vpasexec := 146;

         IF pskipfusion = 1
         THEN
            /* Resto de recibos*/
            FOR tiprec IN (SELECT DISTINCT r.ctiprec
                                      FROM recibos r, detmovsegurocol d
                                     WHERE r.sseguro = d.sseguro_cert
                                       AND r.nmovimi = d.nmovimi_cert
                                       AND d.sseguro_0 = psseguro
                                       AND d.nmovimi_0 = v_mov
                                       AND r.ctiprec NOT IN (13, 15)
                                       AND NOT EXISTS (
                                                   SELECT a.nrecibo
                                                     FROM adm_recunif a
                                                    WHERE a.nrecibo =
                                                                     r.nrecibo)
                           UNION
                           SELECT DISTINCT r.ctiprec
                                      FROM recibos r
                                     WHERE r.sseguro = psseguro
                                       AND r.nmovimi = v_mov
                                       AND r.ctiprec NOT IN (13, 15)
                                       AND NOT EXISTS (
                                                   SELECT a.nrecibo
                                                     FROM adm_recunif a
                                                    WHERE a.nrecibo =
                                                                     r.nrecibo)
                                  ORDER BY ctiprec)
            LOOP
               t_recibo := NULL;
               t_recibo := t_lista_id ();
               vpasexec := 147;
               vpasexec := 15;

               FOR rec IN (SELECT r.nrecibo
                             FROM recibos r, detmovsegurocol d
                            WHERE r.sseguro = d.sseguro_cert
                              AND r.nmovimi = d.nmovimi_cert
                              AND r.ctiprec = tiprec.ctiprec
                              AND d.sseguro_0 = psseguro
                              AND d.nmovimi_0 = v_mov
                              AND NOT EXISTS (SELECT a.nrecibo
                                                FROM adm_recunif a
                                               WHERE a.nrecibo = r.nrecibo)
                           UNION
                           SELECT r.nrecibo
                             FROM recibos r
                            WHERE r.sseguro = psseguro
                              AND r.nmovimi = v_mov
                              AND r.ctiprec = tiprec.ctiprec
                              AND NOT EXISTS (SELECT a.nrecibo
                                                FROM adm_recunif a
                                               WHERE a.nrecibo = r.nrecibo)
                              AND NOT EXISTS (SELECT a.nrecunif
                                                FROM adm_recunif a
                                               WHERE a.nrecunif = r.nrecibo))
               LOOP
                  t_recibo.EXTEND;
                  t_recibo (t_recibo.LAST) := ob_lista_id ();
                  t_recibo (t_recibo.LAST).idd := rec.nrecibo;
               END LOOP;

               vpasexec := 16;

               IF t_recibo IS NOT NULL
               THEN
                  IF t_recibo.COUNT > 0
                  THEN
                     vpasexec := 17;
                     vnumerr :=
                        pac_gestion_rec.f_agruparecibo (vsproduc,
                                                        vfefecto,
                                                        f_sysdate,
                                                        vcempres,
                                                        t_recibo,
                                                        tiprec.ctiprec
                                                       );

                     IF vnumerr <> 0
                     THEN
                        mensajes := NULL;
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              vnumerr
                                                             );
                        RAISE e_object_error;
                     END IF;

                     /* Si se han creado y unificado recibos, cambiamos el CMOTMOV*/
                     vpasexec := 18;

                     IF v_issuplem_0
                     THEN
                        UPDATE movseguro
                           SET cmotmov = 997
                         WHERE sseguro = psseguro AND nmovimi = v_mov;
                     END IF;

                     vpasexec := 19;

                     SELECT MAX (nrecibo)
                       INTO v_nrecunif
                       FROM recibos
                      WHERE sseguro = psseguro
                        AND nmovimi = v_mov
                        AND ctiprec = tiprec.ctiprec;

                     IF v_sproces IS NOT NULL
                     THEN
                        vpasexec := 21;
                        v_nprolin := NULL;

                        IF v_nrecunif IS NOT NULL
                        THEN
                           vnumerr :=
                              f_proceslin (v_sproces,
                                              f_axis_literales (9904025,
                                                                f_usu_idioma
                                                               )
                                           || '. '
                                           || f_axis_literales (102302,
                                                                f_usu_idioma
                                                               )
                                           || ' = '
                                           || tiprec.ctiprec,
                                           v_nrecunif,
                                           v_nprolin,
                                           4
                                          );
                        ELSE
                           vnumerr :=
                              f_proceslin (v_sproces,
                                              f_axis_literales (9901207,
                                                                f_usu_idioma
                                                               )
                                           || '. '
                                           || f_axis_literales (102302,
                                                                f_usu_idioma
                                                               )
                                           || ' = '
                                           || tiprec.ctiprec,
                                           -1,
                                           v_nprolin,
                                           1
                                          );
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         ELSE
            /* Resto de recibos*/
            FOR tiprec IN (SELECT DISTINCT r.ctiprec
                                      FROM recibos r, detmovsegurocol d
                                     WHERE r.sseguro = d.sseguro_cert
                                       AND r.nmovimi = d.nmovimi_cert
                                       AND d.sseguro_0 = psseguro
                                       AND d.nmovimi_0 = v_mov
                                       AND r.ctiprec NOT IN (13, 15)
                                       AND NOT EXISTS (
                                                   SELECT a.nrecibo
                                                     FROM adm_recunif a
                                                    WHERE a.nrecibo =
                                                                     r.nrecibo)
                           UNION
                           SELECT DISTINCT r.ctiprec
                                      FROM recibos r
                                     WHERE r.sseguro = psseguro
                                       AND r.nmovimi = v_mov
                                       AND r.ctiprec NOT IN (13, 15)
                                       AND NOT EXISTS (
                                                   SELECT a.nrecibo
                                                     FROM adm_recunif a
                                                    WHERE a.nrecibo =
                                                                     r.nrecibo)
                                  ORDER BY ctiprec)
            LOOP
               v_array (tiprec.ctiprec) := NULL;
               v_array (tiprec.ctiprec) := t_lista_id ();
               vpasexec := 15;

               FOR rec IN (SELECT r.nrecibo
                             FROM recibos r, detmovsegurocol d
                            WHERE r.sseguro = d.sseguro_cert
                              AND r.nmovimi = d.nmovimi_cert
                              AND r.ctiprec = tiprec.ctiprec
                              AND d.sseguro_0 = psseguro
                              AND d.nmovimi_0 = v_mov
                              AND NOT EXISTS (SELECT a.nrecibo
                                                FROM adm_recunif a
                                               WHERE a.nrecibo = r.nrecibo)
                           UNION
                           SELECT r.nrecibo
                             FROM recibos r
                            WHERE r.sseguro = psseguro
                              AND r.nmovimi = v_mov
                              AND r.ctiprec = tiprec.ctiprec
                              AND NOT EXISTS (SELECT a.nrecibo
                                                FROM adm_recunif a
                                               WHERE a.nrecibo = r.nrecibo)
                              AND NOT EXISTS (SELECT a.nrecunif
                                                FROM adm_recunif a
                                               WHERE a.nrecunif = r.nrecibo))
               LOOP
                  v_array (tiprec.ctiprec).EXTEND;
                  v_array (tiprec.ctiprec) (v_array (tiprec.ctiprec).LAST) :=
                                                               ob_lista_id
                                                                          ();
                  v_array (tiprec.ctiprec) (v_array (tiprec.ctiprec).LAST).idd :=
                                                                  rec.nrecibo;
               END LOOP;
            END LOOP;

            vpasexec := 16;

            IF v_array IS NOT NULL
            THEN
               v_totalp := 0;
               v_totaln := 0;
               t_recibo := NULL;
               t_recibo := t_lista_id ();
               vpasexec := 161;

               /*------- Movimientos positivos ---------*/
               /* Producción*/
               IF v_array.EXISTS (0)
               THEN
                  IF v_array (0).COUNT > 0
                  THEN
                     vpasexec := 162;

                     FOR i IN v_array (0).FIRST .. v_array (0).LAST
                     LOOP
                        vpasexec := 163;

                        BEGIN
                           SELECT itotalr
                             INTO v_total_pos
                             FROM vdetrecibos
                            WHERE nrecibo = v_array (0) (i).idd;

                           v_totalp := v_totalp + v_total_pos;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              NULL;
                        END;

                        t_recibo.EXTEND;
                        t_recibo (t_recibo.LAST) := ob_lista_id ();
                        t_recibo (t_recibo.LAST).idd := v_array (0) (i).idd;
                     END LOOP;
                  END IF;
               END IF;

               /*------- Movimientos positivos ---------*/
               /* Recibos de cartera*/
               IF v_array.EXISTS (3)
               THEN
                  IF v_array (3).COUNT > 0
                  THEN
                     vpasexec := 162;

                     FOR i IN v_array (3).FIRST .. v_array (3).LAST
                     LOOP
                        vpasexec := 163;

                        BEGIN
                           SELECT itotalr
                             INTO v_total_pos
                             FROM vdetrecibos
                            WHERE nrecibo = v_array (3) (i).idd;

                           v_totalp := v_totalp + v_total_pos;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              NULL;
                        END;

                        t_recibo.EXTEND;
                        t_recibo (t_recibo.LAST) := ob_lista_id ();
                        t_recibo (t_recibo.LAST).idd := v_array (3) (i).idd;
                     END LOOP;
                  END IF;
               END IF;

               /* Suplementos*/
               IF v_array.EXISTS (1)
               THEN
                  IF v_array (1).COUNT > 0
                  THEN
                     vpasexec := 164;

                     FOR i IN v_array (1).FIRST .. v_array (1).LAST
                     LOOP
                        vpasexec := 165;

                        BEGIN
                           SELECT itotalr
                             INTO v_total_pos
                             FROM vdetrecibos
                            WHERE nrecibo = v_array (1) (i).idd;

                           v_totalp := v_totalp + v_total_pos;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              NULL;
                        END;

                        t_recibo.EXTEND;
                        t_recibo (t_recibo.LAST) := ob_lista_id ();
                        t_recibo (t_recibo.LAST).idd := v_array (1) (i).idd;
                     END LOOP;
                  END IF;
               END IF;

               /*------- Movimientos negativos ---------*/
               /* extornos*/
               IF v_array.EXISTS (9)
               THEN
                  IF v_array (9).COUNT > 0
                  THEN
                     vpasexec := 170;

                     FOR i IN v_array (9).FIRST .. v_array (9).LAST
                     LOOP
                        vpasexec := 171;

                        BEGIN
                           SELECT itotalr
                             INTO v_total_neg
                             FROM vdetrecibos
                            WHERE nrecibo = v_array (9) (i).idd;

                           v_totaln := v_totaln + v_total_neg;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              NULL;
                        END;

                        t_recibo.EXTEND;
                        t_recibo (t_recibo.LAST) := ob_lista_id ();
                        t_recibo (t_recibo.LAST).idd := v_array (9) (i).idd;
                     END LOOP;
                  END IF;
               END IF;

               vpasexec := 172;

               IF v_totalp >= v_totaln
               THEN
                  v_tiprec := 1;
               ELSE
                  v_tiprec := 9;
               END IF;

               IF t_recibo.COUNT > 0
               THEN
                  vpasexec := 17;
                  vnumerr :=
                     pac_gestion_rec.f_agruparecibo (vsproduc,
                                                     vfefecto,
                                                     f_sysdate,
                                                     vcempres,
                                                     t_recibo,
                                                     v_tiprec,
                                                     1
                                                    );

                  IF vnumerr <> 0
                  THEN
                     mensajes := NULL;
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           vnumerr
                                                          );
                     RAISE e_object_error;
                  END IF;

                  /* Si se han creado y unificado recibos, cambiamos el CMOTMOV*/
                  vpasexec := 18;

                  IF v_issuplem_0
                  THEN
                     UPDATE movseguro
                        SET cmotmov = 997
                      WHERE sseguro = psseguro AND nmovimi = v_mov;
                  END IF;

                  vpasexec := 19;

                  SELECT MAX (nrecibo)
                    INTO v_nrecunif
                    FROM recibos
                   WHERE sseguro = psseguro
                     AND nmovimi = v_mov
                     AND ctiprec = v_tiprec;

                  /* BUG 0026035 - 12/02/2013 - JMF  antes --BUG 23183-XVM-08/11/2012*/
                  IF v_nrecunif IS NOT NULL
                  THEN
                     vpasexec := 20;

                     UPDATE detrecibos
                        SET iconcep = ABS (iconcep)
                      WHERE nrecibo = v_nrecunif;
                  END IF;

                  IF v_sproces IS NOT NULL
                  THEN
                     vpasexec := 21;
                     v_nprolin := NULL;

                     IF v_nrecunif IS NOT NULL
                     THEN
                        vnumerr :=
                           f_proceslin (v_sproces,
                                           f_axis_literales (9904025,
                                                             f_usu_idioma
                                                            )
                                        || '. '
                                        || f_axis_literales (102302,
                                                             f_usu_idioma
                                                            )
                                        || ' = '
                                        || v_tiprec,
                                        v_nrecunif,
                                        v_nprolin,
                                        4
                                       );
                     ELSE
                        vnumerr :=
                           f_proceslin (v_sproces,
                                           f_axis_literales (9901207,
                                                             f_usu_idioma
                                                            )
                                        || '. '
                                        || f_axis_literales (102302,
                                                             f_usu_idioma
                                                            )
                                        || ' = '
                                        || v_tiprec,
                                        -1,
                                        v_nprolin,
                                        1
                                       );
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         vpasexec := 1471;

         /* Recibos de retorno*/
         FOR tiprec IN (SELECT DISTINCT r.ctiprec
                                   FROM recibos r, detmovsegurocol d
                                  WHERE r.sseguro = d.sseguro_cert
                                    AND r.nmovimi = d.nmovimi_cert
                                    AND d.sseguro_0 = psseguro
                                    AND d.nmovimi_0 = v_mov
                                    AND r.ctiprec IN (13, 15)
                                    AND NOT EXISTS (
                                                   SELECT a.nrecibo
                                                     FROM adm_recunif a
                                                    WHERE a.nrecibo =
                                                                     r.nrecibo)
                        UNION
                        SELECT DISTINCT r.ctiprec
                                   FROM recibos r
                                  WHERE r.sseguro = psseguro
                                    AND r.nmovimi = v_mov
                                    AND r.ctiprec IN (13, 15)
                                    AND NOT EXISTS (
                                                   SELECT a.nrecibo
                                                     FROM adm_recunif a
                                                    WHERE a.nrecibo =
                                                                     r.nrecibo)
                               ORDER BY ctiprec)
         LOOP
            t_recibo := NULL;
            t_recibo := t_lista_id ();
            vpasexec := 147;

            FOR pers IN (SELECT DISTINCT r.sperson
                                    FROM recibos r, detmovsegurocol d
                                   WHERE r.sseguro = d.sseguro_cert
                                     AND r.nmovimi = d.nmovimi_cert
                                     AND r.ctiprec = tiprec.ctiprec
                                     AND d.sseguro_0 = psseguro
                                     AND d.nmovimi_0 = v_mov
                                     AND NOT EXISTS (
                                                   SELECT a.nrecibo
                                                     FROM adm_recunif a
                                                    WHERE a.nrecibo =
                                                                     r.nrecibo)
                         UNION
                         SELECT DISTINCT r.sperson
                                    FROM recibos r
                                   WHERE r.sseguro = psseguro
                                     AND r.nmovimi = v_mov
                                     AND r.ctiprec = tiprec.ctiprec
                                     AND NOT EXISTS (
                                                   SELECT a.nrecibo
                                                     FROM adm_recunif a
                                                    WHERE a.nrecibo =
                                                                     r.nrecibo)
                                     AND NOT EXISTS (
                                                  SELECT a.nrecunif
                                                    FROM adm_recunif a
                                                   WHERE a.nrecunif =
                                                                     r.nrecibo))
            LOOP
               vpasexec := 15;

               FOR rec IN (SELECT r.nrecibo
                             FROM recibos r, detmovsegurocol d
                            WHERE r.sseguro = d.sseguro_cert
                              AND r.nmovimi = d.nmovimi_cert
                              AND r.ctiprec = tiprec.ctiprec
                              AND NVL (r.sperson, -1) = NVL (pers.sperson, -1)
                              AND d.sseguro_0 = psseguro
                              AND d.nmovimi_0 = v_mov
                              AND NOT EXISTS (SELECT a.nrecibo
                                                FROM adm_recunif a
                                               WHERE a.nrecibo = r.nrecibo)
                           UNION
                           SELECT r.nrecibo
                             FROM recibos r
                            WHERE r.sseguro = psseguro
                              AND r.nmovimi = v_mov
                              AND r.ctiprec = tiprec.ctiprec
                              AND NVL (r.sperson, -1) = NVL (pers.sperson, -1)
                              AND NOT EXISTS (SELECT a.nrecibo
                                                FROM adm_recunif a
                                               WHERE a.nrecibo = r.nrecibo)
                              AND NOT EXISTS (SELECT a.nrecunif
                                                FROM adm_recunif a
                                               WHERE a.nrecunif = r.nrecibo))
               LOOP
                  t_recibo.EXTEND;
                  t_recibo (t_recibo.LAST) := ob_lista_id ();
                  t_recibo (t_recibo.LAST).idd := rec.nrecibo;
               END LOOP;

               vpasexec := 16;

               IF t_recibo IS NOT NULL
               THEN
                  IF t_recibo.COUNT > 0
                  THEN
                     vpasexec := 17;
                     vnumerr :=
                        pac_gestion_rec.f_agruparecibo (vsproduc,
                                                        vfefecto,
                                                        f_sysdate,
                                                        vcempres,
                                                        t_recibo,
                                                        tiprec.ctiprec
                                                       );

                     IF vnumerr <> 0
                     THEN
                        mensajes := NULL;
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              vnumerr
                                                             );
                        RAISE e_object_error;
                     END IF;

                     /* Si se han creado y unificado recibos, cambiamos el CMOTMOV*/
                     vpasexec := 18;

                     IF v_issuplem_0
                     THEN
                        UPDATE movseguro
                           SET cmotmov = 997
                         WHERE sseguro = psseguro AND nmovimi = v_mov;
                     END IF;

                     vpasexec := 19;

                     SELECT MAX (nrecibo)
                       INTO v_nrecunif
                       FROM recibos
                      WHERE sseguro = psseguro
                        AND nmovimi = v_mov
                        AND ctiprec = tiprec.ctiprec;

                     /* BUG 0026035 - 12/02/2013 - JMF  antes --BUG 23183-XVM-08/11/2012*/
                     IF v_nrecunif IS NOT NULL
                     THEN
                        vpasexec := 20;

                        UPDATE recibos
                           SET sperson = pers.sperson
                         WHERE nrecibo = v_nrecunif;
                     END IF;

                     IF v_sproces IS NOT NULL
                     THEN
                        vpasexec := 21;
                        v_nprolin := NULL;

                        IF v_nrecunif IS NOT NULL
                        THEN
                           vnumerr :=
                              f_proceslin (v_sproces,
                                              f_axis_literales (9904025,
                                                                f_usu_idioma
                                                               )
                                           || '. '
                                           || f_axis_literales (102302,
                                                                f_usu_idioma
                                                               )
                                           || ' = '
                                           || tiprec.ctiprec,
                                           v_nrecunif,
                                           v_nprolin,
                                           4
                                          );
                        ELSE
                           vnumerr :=
                              f_proceslin (v_sproces,
                                              f_axis_literales (9901207,
                                                                f_usu_idioma
                                                               )
                                           || '. '
                                           || f_axis_literales (102302,
                                                                f_usu_idioma
                                                               )
                                           || ' = '
                                           || tiprec.ctiprec,
                                           -1,
                                           v_nprolin,
                                           1
                                          );
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
      END IF;

      /* Bug 29665/163854 - 22/01/2014 - AMC*/
      UPDATE movseguro m
         SET m.femisio = f_sysdate
       WHERE m.sseguro = psseguro AND m.nmovimi = v_mov;

      UPDATE seguros
         SET csituac = 0,
             nsuplem = vnsuplem
       WHERE sseguro = psseguro;

      /* Fi Bug 29665/163854 - 22/01/2014 - AMC*/
      vcontinuaemitir := 0;

      /*Si se continua con la emision.*/
      IF vcontinuaemitir <> 1
      THEN
         /* Bug 24278 - APD - 03/12/2012*/
         /* Si es el certificado 0 y es una poliza administrada*/
         IF     pac_seguros.f_get_escertifcero (NULL, psseguro) = 1
            AND pac_seguros.f_es_col_admin (psseguro, 'SEG') = 1
         THEN
            vcestadocol := pac_movseguro.f_get_cestadocol (psseguro);

            IF NVL (vcestadocol, 0) = 0
            THEN
               vnumerr := pac_movseguro.f_set_cestadocol (psseguro, 1);

               IF vnumerr <> 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;

         /* fin Bug 24278 - APD - 03/12/2012*/
         vpasexec := 6;
         /* Inicializamos los mensajes para mostrar otro ms especfico*/
         mensajes := NULL;
         pac_iobj_mensajes.crea_nuevo_mensaje
                            (mensajes,
                             2,
                             0,
                                f_axis_literales
                                                (9904272,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                             || ' '
                             || f_axis_literales
                                                (9000493,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                             || ': '
                             || v_sproces
                            );
      END IF;

      COMMIT;
      pac_seguros.p_modificar_seguro (psseguro, 0);
      vnumerr := f_procesfin (v_sproces, 0);

      IF vcontinuaemitir <> 1
      THEN
         /* BUG 28263 - 05/11/2013 - FPG - inicio*/
         SELECT NVL (MAX (nmovimi), 1)
           INTO vnmovimi
           FROM movseguro
          WHERE sseguro = psseguro;

         IF vnumerr = 0
         THEN
            vnumerr :=
               pac_md_bpm.f_lanzar_proceso (psseguro,
                                            vnmovimi,
                                            NULL,
                                            '*',
                                            'EMITIDA',
                                            mensajes
                                           );
            COMMIT;

            IF vnumerr <> 0
            THEN
               /*pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);*/
               /*RAISE e_object_error;*/
               NULL;
            /*continuo*/
            END IF;
         END IF;
      /* BUG 28263 - 05/11/2013 - FPG - final*/
      END IF;

      FOR i IN (SELECT   s.sseguro, s.cidioma,
                         pac_isqlfor.f_max_nmovimi (s.sseguro) nmovimi,
                         ppc.ctipo
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo IN (8)
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo)
      LOOP
         vt_iax_impresion :=
            pac_md_impresion.f_get_documprod_tipo (i.sseguro,
                                                   i.ctipo,
                                                   f_usu_idioma,
                                                   mensajes
                                                  );
      END LOOP;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         /* JLTS Se adiciona la siguiente linea*/
         ROLLBACK;

         DECLARE
            v_creteni   NUMBER;
         BEGIN
            SELECT creteni
              INTO v_creteni
              FROM seguros
             WHERE sseguro = psseguro;

            IF v_creteni = 21
            THEN
               pac_seguros.p_modificar_seguro (psseguro, 0);
            END IF;
         END;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         /* JLTS Se adiciona la siguiente linea*/
         ROLLBACK;

         DECLARE
            v_creteni   NUMBER;
         BEGIN
            SELECT creteni
              INTO v_creteni
              FROM seguros
             WHERE sseguro = psseguro;

            IF v_creteni = 21
            THEN
               pac_seguros.p_modificar_seguro (psseguro, 0);
            END IF;
         END;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         /* JLTS Se adiciona la siguiente linea*/
         ROLLBACK;

         DECLARE
            v_creteni   NUMBER;
         BEGIN
            SELECT creteni
              INTO v_creteni
              FROM seguros
             WHERE sseguro = psseguro;

            IF v_creteni = 21
            THEN
               pac_seguros.p_modificar_seguro (psseguro, 0);
            END IF;
         END;

         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_lanzajob_emitecol_admin;

   /* Bug 29665/163095 - 13/01/2014 - AMC*/
   FUNCTION f_num_certif (
      pnpoliza   IN       NUMBER,
      psseguro   IN       NUMBER,
      pcreteni   IN       NUMBER,
      pcuantos   IN OUT   NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam        VARCHAR2 (500)
         :=    'pnpoliza:'
            || pnpoliza
            || ' psseguro:'
            || psseguro
            || ' pcreteni:'
            || pcreteni;
      vpasexec      NUMBER (8)     := 1;
      vobjectname   VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_num_certif';
      v_fecha       DATE;
   BEGIN
      BEGIN
         SELECT m.fmovimi
           INTO v_fecha
           FROM seguros s, movseguro m
          WHERE s.npoliza = pnpoliza
            AND s.ncertif = 0
            AND s.sseguro = m.sseguro
            AND m.cmotmov = 996
            AND m.cmotven = 998
            AND m.nmovimi =
                   (SELECT MAX (m2.nmovimi)
                      FROM movseguro m2
                     WHERE m2.sseguro = m.sseguro
                       AND m2.cmotmov = m.cmotmov
                       AND m2.cmotven = 998);         /* de abrir suplemento*/
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT m.fefecto
                 INTO v_fecha
                 FROM seguros s, movseguro m
                WHERE s.npoliza = pnpoliza
                  AND s.ncertif = 0
                  AND s.sseguro = m.sseguro
                  AND m.cmotmov = 100;
            /* de alta de colectivo (cobro anticipado)*/
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_fecha := f_sysdate;
            END;
      END;

      SELECT COUNT (1)
        INTO pcuantos
        FROM seguros
       WHERE npoliza = pnpoliza
         AND ncertif <> 0
         AND (   csituac IN (4, 5)
              OR (    csituac = 2
                  AND EXISTS (
                         SELECT 1
                           FROM movseguro
                          WHERE sseguro = seguros.sseguro
                            AND cmovseg = 3
                            AND fmovimi >= v_fecha
                            /* Bug 26151 - APD - 01/03/2013*/
                            AND nmovimi NOT IN (
                                   SELECT nmovimi_cert
                                     FROM detmovsegurocol
                                    WHERE sseguro_0 = psseguro
                                      AND sseguro_cert = seguros.sseguro)
                                                                         /* fin Bug 26151 - APD - 01/03/2013*/
                      )
                 )
             )
         AND (   (creteni = 0 AND pcreteni = 0)
              OR (creteni = creteni AND pcreteni <> 0)
             );

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_num_certif;

   /*************************************************************************
   Establece las preguntas automaticas asignadas al producto para insertalas en la poliza
   param in pnmovimi  :    código de movimiento
   param in pfefecto  :    fecha de efecto
   param in out ppoliza :    Objeto póliza E/S
   param in out preg :    Preguntas de la póliza E/S
   param in out mensajes : mensajes de error
   param in pnriesgo  :    Identificador de riesgo tratado
   param in pcgarant  :    Identificador de garantÃ­a tratada
   return             :    NUMBER
   *************************************************************************/
   FUNCTION f_grabar_automatriesgo (
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      ppoliza    IN OUT   ob_iax_poliza,
      preg       IN OUT   t_iax_preguntas,
      mensajes   OUT      t_iax_mensajes,
      pnriesgo   IN       NUMBER,
      pcgarant   IN       NUMBER
   )
      RETURN NUMBER
   IS
      vtprefor         VARCHAR2 (100);
      v_resp           NUMBER;
      /*preg        T_IAX_PREGUNTAS;*/
      num_err          NUMBER;
      vaux             NUMBER;
      w_err            PLS_INTEGER;
      w_pas_exec       PLS_INTEGER    := 1;
      w_param          VARCHAR2 (500)
         := 'parametres: pnmovimi =' || pnmovimi || ' pfefecto = '
            || pfefecto;
      w_object         VARCHAR2 (200)
                                := 'PAC_MD_PRODUCCION.f_grabar_automatriesgo';
      vdisco           VARCHAR2 (1);
      v_cont_est       NUMBER;
      v_cont_rea       NUMBER;
      v_cont_est_gar   NUMBER;
      v_cont_gar       NUMBER;
      vesccero         NUMBER;
      v_ctippre        NUMBER;
      xxsesion         NUMBER;
      vtmodalidad      NUMBER;
      vresultado       NUMBER;
   BEGIN
      IF ppoliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        -456,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_param_error;
      END IF;

      w_pas_exec := 2;

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      SELECT DECODE (pcgarant, NULL, 'R', 'G')
        INTO vdisco
        FROM DUAL;

      w_pas_exec := 3;

      IF preg IS NOT NULL
      THEN
         IF preg.COUNT > 0
         THEN
            FOR i IN preg.FIRST .. preg.LAST
            LOOP
               w_pas_exec := 4;

               IF pac_mdpar_productos.f_es_automatica_pre_tarif
                                                 (ppoliza.det_poliza.sproduc,
                                                  preg (i).cpregun,
                                                  vdisco,
                                                  mensajes,
                                                  pcgarant
                                                 ) = 1
               THEN
                  w_pas_exec := 5;
                  vtprefor :=
                     pac_mdpar_productos.f_get_tpreforsemi
                                                 (ppoliza.det_poliza.sproduc,
                                                  preg (i).cpregun,
                                                  vdisco,
                                                  mensajes,
                                                  pcgarant
                                                 );
                  w_pas_exec := 6;
                  /*w_pas_exec := 73;*/
                  num_err :=
                     pac_albsgt.f_tprefor (vtprefor,
                                           'EST',
                                           ppoliza.det_poliza.sseguro,
                                           pnriesgo,
                                           pfefecto,
                                           pnmovimi,
                                           pcgarant,
                                           v_resp,
                                           1
                                          );
                  w_pas_exec := 8;
                  preg (i).crespue := v_resp;

                  BEGIN
                     SELECT ctippre
                       INTO v_ctippre
                       FROM codipregun
                      WHERE cpregun = preg (i).cpregun;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_ctippre := 0;
                  END;

                  IF v_ctippre = 4
                  THEN
                     preg (i).trespue := TO_CHAR (v_resp, '09999999');
                  ELSE
                     preg (i).trespue := TO_CHAR (v_resp);
                  END IF;

                  w_pas_exec := 9;
               END IF;
            END LOOP;

            w_err :=
               pac_md_grabardatos.f_grabarpreguntasriesgo (preg,
                                                           pnriesgo,
                                                           mensajes
                                                          );

            IF w_err <> 0
            THEN
               w_pas_exec := 10;
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      w_pas_exec := 11;
      RETURN (0);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000005,
                                            w_pas_exec,
                                            w_param
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000006,
                                            w_pas_exec,
                                            w_param
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000001,
                                            w_pas_exec,
                                            w_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (1);
   END f_grabar_automatriesgo;

   FUNCTION f_grabar_modalidadriesgo (
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      ppoliza    IN OUT   ob_iax_poliza,
      preg       IN OUT   t_iax_preguntas,
      mensajes   OUT      t_iax_mensajes,
      pnriesgo   IN       NUMBER,
      pcgarant   IN       NUMBER
   )
      RETURN NUMBER
   IS
      vtprefor         VARCHAR2 (100);
      v_resp           NUMBER;
      /*preg        T_IAX_PREGUNTAS;*/
      num_err          NUMBER;
      vaux             NUMBER;
      w_err            PLS_INTEGER;
      w_pas_exec       PLS_INTEGER    := 1;
      w_param          VARCHAR2 (500)
         := 'parametres: pnmovimi =' || pnmovimi || ' pfefecto = '
            || pfefecto;
      w_object         VARCHAR2 (200)
                              := 'PAC_MD_PRODUCCION.f_grabar_modalidadriesgo';
      vdisco           VARCHAR2 (1);
      v_cont_est       NUMBER;
      v_cont_rea       NUMBER;
      v_cont_est_gar   NUMBER;
      v_cont_gar       NUMBER;
      vesccero         NUMBER;
      v_ctippre        NUMBER;
      xxsesion         NUMBER;
      vtmodalidad      NUMBER;
      vresultado       NUMBER;
   BEGIN
      IF ppoliza.det_poliza IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        -456,
                                        'No se ha inicializado correctamente'
                                       );
         RAISE e_param_error;
      END IF;

      w_pas_exec := 2;

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      SELECT DECODE (pcgarant, NULL, 'R', 'G')
        INTO vdisco
        FROM DUAL;

      w_pas_exec := 3;

      IF preg IS NOT NULL
      THEN
         IF preg.COUNT > 0
         THEN
            FOR i IN preg.FIRST .. preg.LAST
            LOOP
               w_pas_exec := 4;

               BEGIN
                  SELECT tmodalidad
                    INTO vtmodalidad
                    FROM pregunpro pregpro
                   WHERE pregpro.cpregun = preg (i).cpregun
                     AND sproduc = ppoliza.det_poliza.sproduc;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;

               SELECT sgt_sesiones.NEXTVAL
                 INTO xxsesion
                 FROM DUAL;

               IF vtmodalidad IS NOT NULL
               THEN
                  FOR j IN
                     ppoliza.det_poliza.riesgos.FIRST .. ppoliza.det_poliza.riesgos.LAST
                  LOOP
                     IF (    ppoliza.det_poliza.riesgos (j).nriesgo = pnriesgo
                         AND ppoliza.det_poliza.nmovimi = pnmovimi
                        )
                     THEN
                        w_err :=
                           pac_calculo_formulas.calc_formul
                                      (pfefecto,
                                       ppoliza.det_poliza.sproduc,
                                       ppoliza.det_poliza.riesgos (j).cactivi,
                                       pcgarant,
                                       pnriesgo,
                                       ppoliza.det_poliza.sseguro,
                                       vtmodalidad,
                                       vresultado,
                                       pnmovimi,
                                       xxsesion,
                                       1,
                                       pfefecto,
                                       'R',
                                       NULL,
                                       1
                                      );
                        ppoliza.det_poliza.riesgos (j).cmodalidad :=
                                                                    vresultado;
                        p_tab_error
                                (f_sysdate,
                                 f_user,
                                 'PAC_MD_PRODUCCION.f_grabar_modalidadriesgo',
                                 NULL,
                                    ' npoliza ='
                                 || ppoliza.det_poliza.npoliza
                                 || '  pnriesgo ='
                                 || pnriesgo
                                 || '  cpregun ='
                                 || preg (i).cpregun
                                 || '  ctipgru ='
                                 || preg (i).ctipgru
                                 || '  vtmodalidad ='
                                 || vtmodalidad
                                 || '  cmodalidad = '
                                 || vresultado
                                 || '  trespue = '
                                 || preg (i).trespue
                                 || '  crespue = '
                                 || preg (i).crespue,
                                 SQLERRM
                                );
                        EXIT;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      w_pas_exec := 11;
      RETURN (0);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000005,
                                            w_pas_exec,
                                            w_param
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000006,
                                            w_pas_exec,
                                            w_param
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            w_object,
                                            1000001,
                                            w_pas_exec,
                                            w_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN (1);
   END f_grabar_modalidadriesgo;

   /* Bug 29665/163095 - 13/01/2014 - AMC*/
   FUNCTION f_borrar_garantia (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam        VARCHAR2 (500)
         :=    'pcgarant:'
            || pcgarant
            || ' psseguro:'
            || psseguro
            || ' pnriesgo:'
            || pnriesgo;
      vpasexec      NUMBER (8)     := 1;
      vobjectname   VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_borrar_garantia';
      v_fecha       DATE;
      verror        NUMBER;
   BEGIN
      verror :=
         pac_sup_general.f_borrar_garantia (psseguro,
                                            pnriesgo,
                                            pnmovimi,
                                            pcgarant
                                           );

      IF verror <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_borrar_garantia;

   FUNCTION f_get_psu_retenidas (
      poliza           ob_iax_poliza,
      mensajes   OUT   t_iax_mensajes
   )
      RETURN t_iax_psu_retenidas
   IS
      psu_rets     t_iax_psu_retenidas  := t_iax_psu_retenidas ();
      psu_ret      ob_iax_psu_retenidas;
      vpasexec     NUMBER (8)           := 1;
      vparam       VARCHAR2 (1)         := NULL;
      vobject      VARCHAR2 (200) := 'PAC_IAX_PRODUCCION.F_Get_Psu_Retenidas';
      vdetpoliza   ob_iax_detpoliza     := poliza.det_poliza;
      i            NUMBER               := 0;
      j            NUMBER               := 0;

      CURSOR c_rechazos
      IS
         SELECT pr.sseguro, pr.cmotret, pr.cdetmotrec, pr.observ,
                pr.postpper, pr.perpost, pr.ffecaut, pr.cusuaut
           FROM psu_retenidas pr
          WHERE pr.cmotret = 4 AND pr.sseguro = poliza.det_poliza.sseguro;

      CURSOR c_motmov (p_codigo NUMBER)
      IS
         SELECT tmotmov
           FROM motmovseg
          WHERE cmotmov = p_codigo
                AND cidioma = pac_md_common.f_get_cxtidioma;

      CURSOR c_detvalores (p_codigo NUMBER)
      IS
         SELECT tatribu
           FROM detvalores
          WHERE cvalor = 8001026
            AND catribu = p_codigo
            AND cidioma = pac_md_common.f_get_cxtidioma;

      CURSOR c_rechazo_enfermedades
      IS
         SELECT eb.cindex, eb.codenf, eb.desenf
           FROM psu_retenidas pr, icd_declina_undw ID, enfermedades_base eb
          WHERE pr.cmotret = 4
            AND pr.sseguro = poliza.det_poliza.sseguro
            AND pr.sseguro = ID.sseguro
            AND ID.cindex = eb.cindex
         UNION
         SELECT eu.cindex, eu.codenf, eu.desenf
           FROM psu_retenidas pr, enfermedades_undw eu
          WHERE pr.cmotret = 4
            AND pr.sseguro = poliza.det_poliza.sseguro
            AND pr.sseguro = eu.sseguro;
   BEGIN
      IF (vdetpoliza.csituac = 4 AND vdetpoliza.creteni = 3)
      THEN
         i := 0;

         FOR p1 IN c_rechazos
         LOOP
            psu_ret := ob_iax_psu_retenidas ();
            psu_ret.sseguro := p1.sseguro;
            psu_ret.cmotret := p1.cmotret;
            psu_ret.cdetmotrec := p1.cdetmotrec;
            psu_ret.ffecaut := p1.ffecaut;
            psu_ret.cusuaut := p1.cusuaut;

            FOR q1 IN c_motmov (psu_ret.cdetmotrec)
            LOOP
               psu_ret.cdetmotrec_desc := q1.tmotmov;
            END LOOP;

            psu_ret.observ := p1.observ;
            psu_ret.postpper := p1.postpper;
            psu_ret.perpost := p1.perpost;

            FOR q1 IN c_detvalores (psu_ret.perpost)
            LOOP
               psu_ret.perpost_desc := q1.tatribu;
            END LOOP;

            psu_ret.enfermedades := t_iax_enfermedades_base ();
            j := 0;

            FOR q1 IN c_rechazo_enfermedades
            LOOP
               j := j + 1;
               psu_ret.enfermedades.EXTEND ();
               psu_ret.enfermedades (j) :=
                   ob_iax_enfermedades_base (q1.cindex, q1.codenf, q1.desenf);
            END LOOP;

            /* Si no hay enfermedades requiere por lo menos tener el espacio*/
            IF (psu_ret.enfermedades.COUNT = 0)
            THEN
               psu_ret.enfermedades.EXTEND ();
            END IF;

            i := i + 1;
            psu_rets.EXTEND ();
            psu_rets (i) := psu_ret;
         END LOOP;
      END IF;

      RETURN psu_rets;
   END f_get_psu_retenidas;

   /*36507-215125 Funcion apunte retencion cuando salte una PSU KJSC*/
   FUNCTION f_apunte_retencion (
      psseguro   IN       NUMBER,
      /*pcreteni  IN   NUMBER,*/
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam        VARCHAR2 (500)              := 'psseguro:' || psseguro;
      -- || ' pcreteni:' || pcreteni;
      vpasexec      NUMBER (8)                  := 1;
      vobjectname   VARCHAR2 (200)  := 'PAC_MD_PRODUCCION.f_apunte_retencion';
      v_fecha       DATE;
      vnumerr       NUMBER                      := 0;
      v_nsolici     seguros.nsolici%TYPE;
      v_cagente     seguros.cagente%TYPE;
      v_cidioma     seguros.cidioma%TYPE;
      v_ctipage     redcomercial.ctipage%TYPE;
      v_cempres     seguros.cempres%TYPE;
      vidapunte     NUMBER;
      vcreteni      NUMBER;
      v_sseguro     NUMBER;
   BEGIN
      SELECT creteni
        INTO vcreteni
        FROM seguros
       WHERE sseguro = psseguro;

      IF vcreteni = 2
      THEN
         BEGIN
            SELECT s.nsolici, s.cagente, s.cidioma, r.ctipage, s.cempres,
                   s.sseguro
              INTO v_nsolici, v_cagente, v_cidioma, v_ctipage, v_cempres,
                   v_sseguro
              FROM seguros s, redcomercial r
             WHERE s.sseguro = psseguro
               AND s.cagente = r.cagente
               AND r.fmovini =
                      (SELECT MAX (rr.fmovini)
                         FROM redcomercial rr
                        WHERE rr.cempres = s.cempres
                              AND rr.cagente = r.cagente);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vnumerr := 1;
         END;

         vnumerr :=
            pac_agenda.f_set_apunte (NULL,
                                     NULL,
                                     0,
                                     v_nsolici,
                                     1,
                                     0,
                                     0,
                                     NULL,
                                     f_axis_literales (140598, v_cidioma),
                                        f_axis_literales (140598, v_cidioma)
                                     || ' - '
                                     || v_nsolici,
                                     0,
                                     0,
                                     NULL,
                                     NULL,
                                     f_user,
                                     NULL,
                                     f_sysdate,
                                     f_sysdate,
                                     NULL,
                                     vidapunte
                                    );
         vnumerr :=
            pac_agenda.f_set_agenda (vidapunte,
                                     NULL,
                                     NULL,
                                     1,
                                     v_cagente,
                                     1,
                                     v_sseguro,
                                     NULL,
                                     f_user,
                                     v_ctipage,
                                     v_cagente,
                                     v_cempres,
                                     v_cidioma
                                    );
      END IF;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_apunte_retencion;

   FUNCTION f_val_tomador_cbancar (
      psseguro   IN       NUMBER,
      psperson   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam        VARCHAR2 (500)
                       := 'psseguro:' || psseguro || 'psperson: ' || psperson;
      -- || ' pcreteni:' || pcreteni;
      vpasexec      NUMBER (8)     := 1;
      vobjectname   VARCHAR2 (200)
                                 := 'PAC_MD_PRODUCCION.f_val_tomador_cbancar';
      v_fecha       DATE;
      vnumerr       NUMBER         := 0;
      v_cbancar     VARCHAR2 (100);
      v_sperson     NUMBER;
      v_count       NUMBER;
      vnpoliza      NUMBER;
      vsseguro      NUMBER;
   BEGIN
      vpasexec := 1;

      SELECT npoliza
        INTO vnpoliza
        FROM estseguros
       WHERE sseguro = psseguro;

      SELECT sseguro
        INTO vsseguro
        FROM seguros
       WHERE npoliza = vnpoliza;

      SELECT sperson
        INTO v_sperson
        FROM tomadores
       WHERE sseguro = vsseguro AND nordtom = (SELECT MIN (nordtom)
                                                 FROM tomadores t1
                                                WHERE t1.sseguro = vsseguro);

      IF v_sperson <> psperson
      THEN
         vpasexec := 2;

         SELECT NVL (cbancar, '0')
           INTO v_cbancar
           FROM seguros
          WHERE sseguro = vsseguro;

         vpasexec := 3;

         IF v_cbancar <> '0'
         THEN
            vpasexec := 4;

            SELECT COUNT (1)
              INTO v_count
              FROM estper_ccc
             WHERE sperson = psperson;

            vpasexec := 5;

            IF v_count = 0
            THEN
               UPDATE estseguros
                  SET cbancar = NULL
                WHERE sseguro = psseguro;
            END IF;
         END IF;
      END IF;

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_val_tomador_cbancar;

   -- Bug  - 04/04//2016 - JMT
   FUNCTION f_get_datoscontacto (
      npoliza    IN       NUMBER,
      ncertif    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN t_iax_datos_contacto
   IS
      contact       t_iax_datos_contacto;
      vparam        VARCHAR2 (500)
                           := 'npoliza:' || npoliza || ' ncertif:' || ncertif;
      vpasexec      NUMBER (8)           := 1;
      vobjectname   VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_get_datoscontacto';

      CURSOR cr_v_personas_poliza (npoliza NUMBER, ncertif NUMBER)
      IS
         SELECT   codigopersona, numeropoliza, numerocertif, nombre, apelli1,
                  apelli2, MAX (mail) mail, MAX (telefono) telefono,
                  assegurado, tomador, beneficiario, astipnot, tmtipnot,
                  bftipnot
             FROM v_personas_poliza
            WHERE numeropoliza = npoliza AND numerocertif = ncertif
         GROUP BY codigopersona,
                  numeropoliza,
                  numerocertif,
                  nombre,
                  apelli1,
                  apelli2,
                  assegurado,
                  tomador,
                  beneficiario,
                  astipnot,
                  tmtipnot,
                  bftipnot
         ORDER BY codigopersona, assegurado, tomador, beneficiario;
   BEGIN
      --ComprovaciÃ‚Â¿ dels parÃ‚Â¿metres d'entrada
      IF npoliza IS NULL OR ncertif IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      FOR c IN cr_v_personas_poliza (npoliza, ncertif)
      LOOP
         IF contact IS NULL
         THEN
            contact := t_iax_datos_contacto ();
         END IF;

         vpasexec := 5;
         contact.EXTEND;
         contact (contact.LAST) := ob_iax_datos_contacto ();
         contact (contact.LAST).sperson := c.codigopersona;
         contact (contact.LAST).npoliza := c.numeropoliza;
         contact (contact.LAST).ncertif := c.numerocertif;
         contact (contact.LAST).tnombre := c.nombre;
         contact (contact.LAST).tapelli1 := c.apelli1;
         contact (contact.LAST).tapelli2 := c.apelli2;
         contact (contact.LAST).email := c.mail;
         contact (contact.LAST).telefono := c.telefono;

         IF c.assegurado = 1
         THEN
            contact (contact.LAST).tipopers := '101028';
            contact (contact.LAST).envio := c.astipnot;
         ELSE
            IF c.tomador = 1
            THEN
               contact (contact.LAST).tipopers := '101027';
               contact (contact.LAST).envio := c.tmtipnot;
            ELSE
               IF c.beneficiario = 1
               THEN
                  contact (contact.LAST).tipopers := '9001911';
                  contact (contact.LAST).envio := c.bftipnot;
               ELSE
                  contact (contact.LAST).tipopers := '';
                  contact (contact.LAST).envio := 0;
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN contact;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_get_datoscontacto;

   -- Bug  - 06/04//2016 - JMT
   FUNCTION f_set_datoscontacto (
      npol       IN       NUMBER,
      ncert      IN       NUMBER,
      spers      IN       NUMBER,
      tipopers   IN       NUMBER,
      lmail      IN       NUMBER,
      ltel       IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vparam        VARCHAR2 (500)
         :=    'npoliza:'
            || npol
            || ' ncertif:'
            || ncert
            || ' spers:'
            || spers
            || ' tipopers:'
            || tipopers
            || ' lmail:'
            || lmail
            || ' ltel:'
            || ltel;
      vpasexec      NUMBER (8)     := 1;
      vsseguro      NUMBER;
      vcontact      NUMBER;
      vobjectname   VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_set_datoscontacto';
   BEGIN
      --ComprovaciÃ‚Â¿ dels parÃ‚Â¿metres d'entrada
      IF    npol IS NULL
         OR ncert IS NULL
         OR spers IS NULL
         OR tipopers IS NULL
         OR lmail IS NULL
         OR ltel IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      SELECT s.sseguro
        INTO vsseguro
        FROM seguros s
       WHERE s.npoliza = npol AND s.ncertif = ncert;

      IF lmail = 0
      THEN
         -- no contactar por mail
         IF ltel = 0
         THEN
            -- no contactar
            vcontact := 0;
         ELSE
            -- Contactar solo por telefono
            vcontact := 2;
         END IF;
      ELSE
         -- contactar por mail
         IF ltel = 0
         THEN
            -- contactar solo por mail
            vcontact := 1;
         ELSE
            -- Contactar por telefono y mail
            vcontact := 3;
         END IF;
      END IF;

      IF tipopers = 101028
      THEN
         -- Asegurado
         UPDATE asegurados a
            SET a.ctipnot = vcontact
          WHERE a.sperson = spers AND a.sseguro = vsseguro;
      ELSE
         IF tipopers = 101027
         THEN
            -- Tomador
            UPDATE tomadores a
               SET a.ctipnot = vcontact
             WHERE a.sperson = spers AND a.sseguro = vsseguro;
         ELSE
            IF tipopers = 9001911
            THEN
               -- Beneficiario
               UPDATE beneficiarios a
                  SET a.ctipnot = vcontact
                WHERE a.sperson = spers AND a.sseguro = vsseguro;
            ELSE
               RETURN 0;
            END IF;
         END IF;
      END IF;

      COMMIT;
      RETURN 1;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 0;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 0;
   END f_set_datoscontacto;

   FUNCTION f_borrar_simulaciones (
      psseguro   IN       estseguros.sseguro%TYPE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200) := 'param - psseguro: ' || psseguro;
      vobject    VARCHAR2 (200) := 'pac_md_produccion.f_borrar_simulaciones';
      vborra     NUMBER;
   BEGIN
      /*Comprueba parametro de entrada*/
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vborra := pac_seguros.f_borrar_simulaciones (psseguro);
      vpasexec := 3;
      RETURN vborra;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
   END f_borrar_simulaciones;

   -- Ini  TCS_827 - ACL - 17/02/2019
    /*************************************************************************
      Devuelve las pólizas que cumplan con el criterio de selección
     param out mensajes    : mensajes de error
      return                : ref cursor
    *************************************************************************/
   FUNCTION f_consultapoliza_contrag (
      pramo              IN       NUMBER,
      psproduc           IN       NUMBER,
      pnpoliza           IN       NUMBER,
      pncert             IN       NUMBER DEFAULT -1,
      pnnumide           IN       VARCHAR2,
      psnip              IN       VARCHAR2,
      pbuscar            IN       VARCHAR2,
      pnsolici           IN       NUMBER,
      ptipopersona       IN       NUMBER,
      pcagente           IN       NUMBER,
      pcmatric           IN       VARCHAR2,
      pcpostal           IN       VARCHAR2,
      ptdomici           IN       VARCHAR2,
      ptnatrie           IN       VARCHAR2,
      pcsituac           IN       NUMBER,
      p_filtroprod       IN       VARCHAR2,
      pcpolcia           IN       VARCHAR2,
      pccompani          IN       NUMBER,
      pcactivi           IN       NUMBER,
      pcestsupl          IN       NUMBER,
      pnpolrelacionada   IN       NUMBER,
      pnpolini           IN       VARCHAR2,
      mensajes           IN OUT   t_iax_mensajes,
      pfilage            IN       NUMBER DEFAULT 1,
      pcsucursal         IN       NUMBER DEFAULT NULL,
      pcadm              IN       NUMBER DEFAULT NULL,
      pcmotor            IN       VARCHAR2 DEFAULT NULL,
      pcchasis           IN       VARCHAR2 DEFAULT NULL,
      pnbastid           IN       VARCHAR2 DEFAULT NULL,
      pcmodo             IN       NUMBER DEFAULT NULL,
      pncontrato         IN       VARCHAR2 DEFAULT NULL
   )
      RETURN sys_refcursor
   IS
      cur              sys_refcursor;
      squery           VARCHAR2 (5000);
      buscar           VARCHAR2 (5000)
                        := ' where 1=1 and s.csituac <> 2 and s.creteni <> 4';
      -- TCS_827 - ACL -  06/03/2019 - Se ajusta exclusiones de búsquedas
      subus            VARCHAR2 (500);
      tabtp            VARCHAR2 (30);
      tabtp_ase        VARCHAR2 (20);
      tabtp_con        VARCHAR2 (50);
      tabtp_pag        VARCHAR2 (50);
      auxnom           VARCHAR2 (200);
      v_nom            VARCHAR2 (200);
      empresa          NUMBER;
      nerr             NUMBER;
      v_sentence       VARCHAR2 (500);
      v_query_agente   VARCHAR2 (5000);
      vpasexec         NUMBER (8)      := 1;
      vform            VARCHAR2 (5000) := '';
      vparam           VARCHAR2 (500)
         :=    'psproduc='
            || psproduc
            || ' pnpoliza: '
            || pnpoliza
            || ' pncert='
            || pncert
            || ' pnnumide='
            || pnnumide
            || ' psnip='
            || psnip
            || ' pbuscar='
            || pbuscar
            || ' ptipopersona='
            || ptipopersona
            || ' pnsolici='
            || pnsolici
            || ' pcmatric='
            || pcmatric
            || ' pcpostal='
            || pcpostal
            || ' ptdomici='
            || ptdomici
            || ' ptnatrie='
            || ptnatrie
            || ' p_filtroprod='
            || p_filtroprod
            || 'pcpolcia='
            || pcpolcia
            || ' pccompani= '
            || pccompani
            || ' pcactivi= '
            || pcactivi
            || ' pcestsupl= '
            || pcestsupl
            || ' pnpolrelacionada= '
            || pnpolrelacionada;
      vobject          VARCHAR2 (200)
                               := 'PAC_MD_PRODUCCION.f_consultapoliza_contrag';
      v_max_reg        NUMBER;
   BEGIN
      /************************************
      buscar :=
         buscar || ' AND ((pac_corretaje.f_tiene_corretaje (s.sseguro) = 1 AND ('
         || pac_md_common.f_get_cxtagente || ' = s.cagente OR '
         || pac_md_common.f_get_cxtagente
         || ' IN (SELECT ctj.cagente FROM age_corretaje ctj WHERE ctj.sseguro = s.sseguro)))'
         || ' OR ((s.cagente, s.cempres) IN (select aa.cagente, aa.cempres from agentes_agente_pol aa)))';
      ************************************/
      v_query_agente := 's.cagente';

      IF p_filtroprod = 'PIGNORACION'
      THEN
         IF NVL
               (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'FILTRO_PLEDGE'
                                           ),
                0
               ) = 1
         THEN
            v_query_agente :=
                  '(SELECT ''1'' FROM agentes a, bloqueoseg b, agentes c '
               || ' WHERE a.sperson(+) = b.sperson'
               || ' AND c.ctipage = 0 '
               || ' AND b.sseguro = s.sseguro '
               || ' AND b.cmotmov = 261 '
               || ' AND (b.ffinal IS NULL OR b.ffinal > TRUNC (f_sysdate))'
               || ' AND NVL(a.cagente, c.cagente) in (SELECT aa.cagente FROM agentes_agente_pol aa)'
               || ' )'
               || ' OR ( s.cagente IN (SELECT aa.cagente FROM   agentes_agente_pol aa) )';
         END IF;
      END IF;

      IF pcmodo IS NULL OR pcmodo = 0
      THEN
         IF p_filtroprod = 'PIGNORACION'
         THEN
            buscar :=
                  buscar
               || ' AND ((pac_corretaje.f_tiene_corretaje (s.sseguro) = 1 AND ('
               || pac_md_common.f_get_cxtagente
               || ' = s.cagente OR '
               || ' exists '
               || ' (SELECT 1 FROM age_corretaje ctj, agentes_agente_pol bb'
               || ' WHERE ctj.sseguro=s.sseguro and bb.cempres=s.cempres and bb.cagente=ctj.cagente)'
               || '))'
               || ' OR exists'
               || v_query_agente
               || ')';
         ELSE
            buscar :=
                  buscar
               || ' AND ((pac_corretaje.f_tiene_corretaje (s.sseguro) = 1 AND ('
               || pac_md_common.f_get_cxtagente
               || ' = s.cagente OR '
               || ' exists '
               || ' (SELECT 1 FROM age_corretaje ctj, agentes_agente_pol bb'
               || ' WHERE ctj.sseguro=s.sseguro and bb.cempres=s.cempres and bb.cagente=ctj.cagente)'
               || '))'
               || ' OR (('
               || v_query_agente
               || ', s.cempres) IN (select aa.cagente, aa.cempres from agentes_agente_pol aa)))';
         END IF;
      END IF;

      IF NVL (psproduc, 0) <> 0
      THEN
         buscar := buscar || ' and s.sproduc =' || psproduc;
      ELSE
         nerr := pac_productos.f_get_filtroprod (p_filtroprod, v_sentence);

         IF nerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         IF v_sentence IS NOT NULL
         THEN
            buscar :=
                  buscar
               || ' and s.sproduc in (select p.sproduc from productos p where'
               || v_sentence
               || ' 1=1)';
         END IF;

         IF pramo IS NOT NULL
         THEN
            buscar :=
                  buscar
               || ' and s.sproduc in (select p.sproduc from productos p where'
               || ' p.cramo = '
               || pramo
               || ' )';
         END IF;
      END IF;

      IF p_filtroprod IN ('SALDAR', 'PRORROGAR')
      THEN
         buscar := buscar || ' and s.csituac = 0 and s.creteni = 0 ';
      END IF;

      IF p_filtroprod = 'SINIESTRO'
      THEN
         buscar := buscar || ' and s.csituac <> 4 ';
      END IF;

      IF pnpoliza IS NOT NULL
      THEN
         buscar :=
             buscar || ' and s.npoliza = ' || CHR (39) || pnpoliza
             || CHR (39);
      END IF;

      IF pnsolici IS NOT NULL
      THEN
         buscar := buscar || ' and s.nsolici = ' || pnsolici;
      END IF;

      IF pnpolini IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro IN ( SELECT SSEGURO from CNVPOLIZAS WHERE POLISSA_INI =  '
            || CHR (39)
            || pnpolini
            || CHR (39)
            || ')';
      END IF;

      IF pnpolrelacionada IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro IN ( select SSEGURO from pregunpolseg where CPREGUN IN (9738, 9739, 9740) AND TRESPUE =  '
            || pnpolrelacionada
            || ')';
      END IF;

      IF pfilage = 0
      THEN
         IF NVL
               (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'FILTRO_AGE'
                                           ),
                0
               ) = 1
         THEN
            buscar :=
                  buscar
               || ' and s.cagente in (SELECT a.cagente
                                            FROM (SELECT     LEVEL nivel, cagente
                                                        FROM redcomercial r
                                                       WHERE
                                                          r.fmovfin is null
                                                  START WITH
                                                          r.cagente = '
               || pac_md_common.f_get_cxtagente ()
               || ' AND r.cempres = '
               || pac_md_common.f_get_cxtempresa ()
               || ' and r.fmovfin is null
                                                  CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
                                                         AND PRIOR r.cempres =(r.cempres + 0)
                                                         and r.fmovfin is null
                                                         AND r.cagente >= 0) rr,
                                                 agentes a
                                           where rr.cagente = a.cagente)';
         END IF;
      END IF;

      IF pcpolcia IS NOT NULL
      THEN
         IF NVL
               (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'BUSCA_POL_ANTIG'
                                           ),
                0
               ) = 1
         THEN
            buscar :=
                  buscar
               || ' and upper(s.cpolcia) = '
               || CHR (39)
               || pcpolcia
               || CHR (39);
         ELSE
            buscar :=
                  buscar
               || ' and upper(s.cpolcia) like '
               || CHR (39)
               || '%'
               || pcpolcia
               || '%'
               || CHR (39);
         END IF;
      END IF;

      IF NVL (pncert, -1) <> -1
      THEN
         buscar := buscar || '  and s.ncertif =' || pncert;
      END IF;

      IF pcagente IS NOT NULL
      THEN
         buscar := buscar || ' and s.cagente = ' || pcagente;
      END IF;

      IF pcsituac IS NOT NULL
      THEN
         buscar := buscar || ' and s.csituac = ' || pcsituac;
      ELSIF pcpolcia IS NULL AND pnpoliza IS NULL AND pnsolici IS NULL
      THEN
         buscar := buscar || ' and s.csituac != 16 ';
      END IF;

      IF pcmatric IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
            || ' where s.sseguro = aut.sseguro and aut.cmatric like ''%'
            || pcmatric
            || '%''';
         buscar := buscar || ') ';
      END IF;

      IF pcmotor IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
            || ' where s.sseguro = aut.sseguro and aut.codmotor like ''%'
            || pcmotor
            || '%''';
         buscar := buscar || ') ';
      END IF;

      IF pcchasis IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
            || ' where s.sseguro = aut.sseguro and aut.cchasis like ''%'
            || pcchasis
            || '%''';
         buscar := buscar || ') ';
      END IF;

      IF pnbastid IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
            || ' where s.sseguro = aut.sseguro and aut.nbastid like ''%'
            || pnbastid
            || '%''';
         buscar := buscar || ') ';
      END IF;

      IF pcpostal IS NOT NULL OR ptdomici IS NOT NULL
      THEN
         vform := vform || ' , sitriesgo sit ';
      END IF;

      IF pccompani IS NOT NULL
      THEN
         buscar := buscar || ' and s.CCOMPANI = ' || pccompani;
      END IF;

      IF pcpostal IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and sit.sseguro = s.sseguro and upper(sit.cpostal) like upper(''%'
            || pcpostal
            || '%'')';
      END IF;

      IF ptdomici IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and sit.sseguro = s.sseguro and upper(sit.tdomici) like upper(''%'
            || ptdomici
            || '%'')';
      END IF;

      IF ptnatrie IS NOT NULL
      THEN
         vform := vform || ' , riesgos rie ';
         buscar :=
               buscar
            || ' and rie.sseguro = s.sseguro and upper(rie.tnatrie) like upper(''%'
            || ptnatrie
            || '%'')';
      END IF;

      IF pcactivi IS NOT NULL
      THEN
         buscar := buscar || ' and s.cactivi = ' || pcactivi;
      END IF;

      IF pcestsupl IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' and EXISTS (SELECT 1 FROM sup_solicitud sup'
            || ' WHERE sup.sseguro = s.sseguro and cestsup = '
            || pcestsupl
            || ')';
      END IF;

      v_nom := ' pac_iax_listvalores.f_get_nametomador(s.sseguro, 1) ';

      IF NVL (ptipopersona, 0) > 0
      THEN
         IF ptipopersona = 1
         THEN
            tabtp := 'TOMADORES';
         ELSIF NVL (ptipopersona, 0) = 2
         THEN
            empresa := f_parinstalacion_n ('EMPRESADEF');

            IF NVL (pac_parametros.f_parempresa_t (empresa, 'NOM_TOM_ASEG'),
                    0
                   ) = 1
            THEN
               v_nom := ' f_nombre(aa.sperson, 1, s.cagente) ';
               tabtp_ase := ', ASEGURADOS aa';
            END IF;
         ELSIF ptipopersona = 3
         THEN
            tabtp_con := ', AUTCONDUCTORES aa';
         ELSIF ptipopersona = 4
         THEN
            tabtp_pag := ', RECIBOS aa';
         END IF;
      END IF;

      IF     (   pnnumide IS NOT NULL
              OR NVL (psnip, ' ') <> ' '
              OR pbuscar IS NOT NULL
             )
         AND NVL (ptipopersona, 0) > 0
      THEN
         IF ptipopersona = 1
         THEN
            tabtp := 'TOMADORES';
         ELSIF ptipopersona = 2
         THEN
            tabtp := 'ASEGURADOS';
         ELSIF ptipopersona = 3
         THEN
            tabtp := 'AUTCONDUCTORES';
         ELSIF ptipopersona = 4
         THEN
            tabtp := 'RECIBOS';
         END IF;

         IF tabtp IS NOT NULL
         THEN
            subus :=
                  ' and s.sseguro IN (SELECT a.sseguro FROM '
               || tabtp
               || ' a, per_detper p, per_personas pp WHERE pp.sperson = p.sperson and a.sperson = p.sperson AND P.CAGENTE = FF_AGENTE_CPERVISIO (S.CAGENTE, F_SYSDATE, S.CEMPRES)';

            IF ptipopersona = 2
            THEN
               subus := subus || ' AND a.ffecfin IS NULL';
            END IF;

            IF pnnumide IS NOT NULL
            THEN
               IF NVL
                     (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NIF_MINUSCULAS'
                                           ),
                      0
                     ) = 1
               THEN
                  subus :=
                        subus
                     || ' AND UPPER(pp.nnumide)= UPPER('
                     || CHR (39)
                     || ff_strstd (pnnumide)
                     || CHR (39)
                     || ')';
               ELSE
                  subus :=
                        subus
                     || ' AND pp.nnumide like '
                     || CHR (39)
                     || '%'
                     || ff_strstd (pnnumide)
                     || '%'
                     || CHR (39)
                     || '';
               END IF;
            END IF;

            IF NVL (psnip, ' ') <> ' '
            THEN
               subus :=
                     subus
                  || ' AND upper(pp.snip)=upper('
                  || CHR (39)
                  || ff_strstd (psnip)
                  || CHR (39)
                  || ')';
            END IF;

            IF pbuscar IS NOT NULL
            THEN
               nerr := f_strstd (pbuscar, auxnom);
               subus :=
                     subus
                  || ' AND upper ( replace ( p.tbuscar, '
                  || CHR (39)
                  || '  '
                  || CHR (39)
                  || ','
                  || CHR (39)
                  || ' '
                  || CHR (39)
                  || ' )) like upper(''%'
                  || auxnom
                  || '%'
                  || CHR (39)
                  || ')';
            END IF;

            subus := subus || ')';
         END IF;
      END IF;

      IF tabtp_ase IS NOT NULL
      THEN
         buscar := buscar || ' AND s.sseguro = aa.sseguro ';
      END IF;

      IF tabtp_con IS NOT NULL
      THEN
         buscar := buscar || ' AND s.sseguro = aa.sseguro ';
      END IF;

      IF tabtp_pag IS NOT NULL
      THEN
         buscar := buscar || ' AND s.sseguro = aa.sseguro ';
      END IF;

      IF pcsucursal IS NOT NULL OR pcadm IS NOT NULL
      THEN
         vform := vform || ' ,seguredcom src ';
         buscar := buscar || ' AND s.sseguro = src.sseguro ';

         IF pcsucursal IS NOT NULL
         THEN
            buscar := buscar || ' AND src.c02 = ' || pcsucursal;
         END IF;

         IF pcadm IS NOT NULL
         THEN
            buscar := buscar || ' AND src.c03 = ' || pcadm;
         END IF;
      END IF;

      IF pcmodo = 1
      THEN
         buscar :=
               buscar
            || ' AND EXISTS (SELECT 1 FROM usuarios u, bloqueoseg b,agentes ag WHERE u.cusuari = '''
            || pac_md_common.f_get_cxtusuario
            || '''
                                  AND b.sseguro = s.sseguro AND b.ffinal IS NULL AND b.cmotmov = 261 AND ag.cagente = u.cdelega AND (Select sperson FROM agentes a
                          WHERE cagente = pac_redcomercial.f_busca_padre(u.cempres, u.cdelega, ag.ctipage, trunc(f_sysdate)) )  = b.sperson ) ';
      END IF;

      IF pncontrato IS NOT NULL
      THEN
         buscar :=
               buscar
            || ' AND EXISTS ( select 1 FROM PREGUNPOLSEG P WHERE p.sseguro = s.sseguro and p.nmovimi = '
            || '  (select max(nmovimi)from pregunpolseg p1 where p1.sseguro = p.sseguro and p1.cpregun = p.cpregun) '
            || ' and p.cpregun = 4097 AND p.trespue = '''
            || pncontrato
            || ''' ) ';
      END IF;

      squery :=
            'SELECT s.sseguro, TO_CHAR(s.npoliza) npoliza, s.ncertif, s.cpolcia,'
         || 'PAC_IAXPAR_PRODUCTOS.f_get_parproducto(''ADMITE_CERTIFICADOS'', s.sproduc) mostra_certif,'
         || v_nom
         || 'AS nombre, PAC_IAX_LISTVALORES.F_Get_Sit_Pol_Detalle(s.sseguro) as situacion,'
         || ' s.sproduc, f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,PAC_MD_COMMON.f_get_cxtidioma) as desproducto,'
         || ' ff_descompania(s.ccompani) ccompani, null nnumide, null cmediad, null ccolabo, s.fefecto fefecto, null csinies, s.femisio femisio, null cplan, null clinea,'
         || ' s.cactivi, ff_desactividad (s.cactivi, s.cramo, PAC_MD_COMMON.f_get_cxtidioma, 2) tactivi, '
         || ' ff_desagente(s.cagente) tagente FROM seguros s '
         || vform
         || tabtp_ase
         || tabtp_con
         || tabtp_pag
         || buscar
         || subus;

      IF NVL
            (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                            'EMP_POL_EXTERNA'
                                           ),
             0
            ) = 1
      THEN
         IF    NVL (pac_parametros.f_parproducto_n (psproduc,
                                                    'PRO_POL_EXTERNA'
                                                   ),
                    0
                   ) = 1
            OR psproduc IS NULL
         THEN
            DECLARE
               vsquery2   VARCHAR2 (4000);
            BEGIN
               vsquery2 :=
                     'select to_number (null) sseguro, es.npoliza, to_number (null) ncertif, null cpolcia, 0 mostra_certif, trim(es.tapell1)||CHR(32)||trim(es.tapell2)||CHR(32)||'', ''||CHR(32)||trim(es.tnombre) nombre,'
                  || ' decode(ctipmov,''B'',ff_desvalorfijo(61,PAC_MD_COMMON.f_get_cxtidioma,2),ff_desvalorfijo(61,PAC_MD_COMMON.f_get_cxtidioma,0)) situacion,'
                  || ' es.sproduc, f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect,1, PAC_MD_COMMON.f_get_cxtidioma) as desproducto,'
                  || ' ff_descompania(p.ccompani) ccompani, es.nnumide, es.cmediad, es.ccolabo, es.fefecto, decode(es.csinies, 1, f_axis_literales(101778,pac_md_common.f_get_cxtidioma), f_axis_literales(101779,pac_md_common.f_get_cxtidioma)) csinies, es.femisio,'
                  || ' pac_propio.f_get_planpoliza(es.idproduc, es.ccompani, es.sproduc) cplan, pac_propio.f_get_lineapoliza(es.idproduc, es.ccompani, es.sproduc) clinea,'
                  || ' to_number (null) cactivi, NULL tactivi, NULL tagente ';
               vsquery2 := vsquery2 || ' from ext_seguros es, productos p ';
               vsquery2 :=
                     vsquery2
                  || ' where es.sproduc = p.sproduc and (es.ccolabo,pac_md_common.f_get_cxtempresa) in (select cagente,cempres from agentes_agente_pol) ';

               IF psproduc IS NOT NULL
               THEN
                  vsquery2 := vsquery2 || ' and p.sproduc = ' || psproduc;
               END IF;

               IF pramo IS NOT NULL
               THEN
                  vsquery2 :=
                        vsquery2
                     || ' and es.sproduc in (select p.sproduc from productos p where'
                     || ' p.cramo = '
                     || pramo
                     || ' )';
               END IF;

               IF pcagente IS NOT NULL
               THEN
                  vsquery2 :=
                        vsquery2
                     || ' and (es.cmediad = '
                     || pcagente
                     || ' or es.ccolabo = '
                     || pcagente
                     || ') ';
               END IF;

               IF pnpoliza IS NOT NULL
               THEN
                  vsquery2 :=
                        vsquery2
                     || ' and es.npoliza = '
                     || CHR (39)
                     || pnpoliza
                     || CHR (39);
               END IF;

               IF pccompani IS NOT NULL
               THEN
                  vsquery2 := vsquery2 || ' and es.ccompani = ' || pccompani;
               END IF;

               IF TRIM (pnnumide) IS NOT NULL
               THEN
                  IF NVL
                        (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NIF_MINUSCULAS'
                                           ),
                         0
                        ) = 1
                  THEN
                     vsquery2 :=
                           vsquery2
                        || ' and UPPER(es.nnumide) = UPPER('
                        || CHR (39)
                        || pnnumide
                        || CHR (39)
                        || ')';
                  ELSE
                     vsquery2 :=
                           vsquery2
                        || ' and es.nnumide = '
                        || CHR (39)
                        || pnnumide
                        || CHR (39);
                  END IF;
               END IF;

               IF pbuscar IS NOT NULL
               THEN
                  vsquery2 :=
                        vsquery2
                     || ' AND FF_STRSTD(TRIM(es.tnombre)||CHR(32)||TRIM(es.tapell1)||CHR(32)||TRIM(es.tapell2)||CHR(32)) LIKE '
                     || CHR (39)
                     || '%'
                     || auxnom
                     || '%'
                     || CHR (39);
               END IF;

               vsquery2 := ' UNION ALL ' || vsquery2;
               squery := squery || vsquery2;
            END;
         END IF;
      END IF;

      squery := squery || ' order by npoliza desc, ncertif desc nulls last';
      v_max_reg := pac_parametros.f_parinstalacion_n ('N_MAX_REG');

      IF p_filtroprod IS NULL OR p_filtroprod <> 'AUTORIZA_MASIVO'
      THEN
         squery :=
             'select * from (' || squery || ') where rownum <= ' || v_max_reg;
      END IF;

      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);

      IF pac_md_log.f_log_consultas (squery,
                                     'PAC_MD_PRODUCCION.F_CONSULTAPOLIZA',
                                     1,
                                     2,
                                     mensajes
                                    ) <> 0
      THEN
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consultapoliza_contrag;

    -- Fin  TCS_827 - ACL - 17/02/2019
    -- INI BUG 3324 - SGM Interaccion del Rango DIAN con la poliza (No. Certificado)
   /***********************************************************************
   Busca el certificado dian de la poliza ligado al movimiento
   param in psseguro     : Numero de seguro
   param in pnmovimi     : Numero de movimiento
   param in out mensajes : mensajes error
   return                : numero certificado DIAN
   ***********************************************************************/
   FUNCTION f_get_certdian (
      psseguro   IN       seguros.sseguro%TYPE,
      pnrecibo   IN       recibos.nrecibo%TYPE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      vpasexec      NUMBER         := 1;
      vparam        VARCHAR2 (1)   := NULL;
      vobject       VARCHAR2 (200) := 'PAC_MD_PRODUCCION.f_get_certdian';
      nerr          NUMBER;
      v_ncertdian   VARCHAR2 (10)  := NULL;
      vnmovimi      NUMBER;
   BEGIN
      BEGIN
         SELECT nmovimi
           INTO vnmovimi
           FROM recibos
          WHERE sseguro = psseguro AND nrecibo = pnrecibo;
      EXCEPTION
         WHEN OTHERS
         THEN
            nerr := SQLCODE;
      END;

      vpasexec := 2;

      BEGIN
         SELECT ncertdian
           INTO v_ncertdian
           FROM rango_dian_movseguro
          WHERE sseguro = psseguro AND nmovimi = vnmovimi;
      EXCEPTION
         WHEN OTHERS
         THEN
            nerr := SQLCODE;
      END;

      RETURN v_ncertdian;
      vpasexec := 3;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN v_ncertdian;
   END f_get_certdian;
-- FIN BUG 3324 - SGM Interaccion del Rango DIAN con la poliza (No. Certificado)
END pac_md_produccion;
/
