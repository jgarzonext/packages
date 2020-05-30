--------------------------------------------------------
--  DDL for Package Body PAC_ISQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ISQL" AS
   /****************************************************************************
      NOMBRE:    PAC_ISQL
      PROPÓSITO: Funciones para impresión de rtf's

      REVISIONES:
      Ver        Fecha       Autor            Descripción
      ---------  ----------  ---------------  ----------------------------------
      2.0        02/03/2009  SBG              1. Modificaciones bug 9289
      3.0        23/04/2009  SBG              1. Modificaciones bug 9472
      4.0        13/05/2009  ICV              3. 10078: IAX - Adaptación impresiones (plantillas)
      5.0        01/07/2009  NMM              4. 10373: APR - condicionado particular.
      6.0        22/07/2009  MSR              3. Bug 10700.
                                                   1.- Escriure múltiples pàgines
                                                   2.- Neteja general del codi
                                                   3.- Arreglar problemes amb literals amb un '
                                                   4.- Controlar multiregistres que tornen valor a NULL
                                                   5.- Ampliar selects a més de 4000 caràcters
                                                   6.- Eliminar limitació a 65 camps
      11.0       10/05/2010   JTS             6. BUG 13104 Diverses modificacions
      12.0       02/06/2010   JTS             7. 14821: CRE - generación de content.xml, escapear caraceteres especiales
      13.0       23/09/2010   JMF             8. 0016033 AGA003 - alta de sinistres (LLAR) impresiones
      14.0       14/05/2015   JLQ             9. BUG 0035712 --Polizas proximas a vencer.
      15.0       26/05/2015   YDA             15. Bug 0035712 Se crean las funciones p_docs_secondreminder y p_docs_finalnotic
      16.0        13/05/2015  ETM              7. Bug 33632/209101: Se modifica la función f_tratamiento_no_pago para generar la plantilla: 'D-1090-102-01 - CANCELLED
   ****************************************************************************/

   --
   -- Tipus privats
   --
   TYPE registro IS TABLE OF VARCHAR2(32000)
      INDEX BY BINARY_INTEGER;

   TYPE vector IS TABLE OF registro
      INDEX BY BINARY_INTEGER;

   --
   -- Constants
   --
   -- Definició de la longitud dels blocs de dades que llegirem / escriurem dels/als fitxers
   -- El màxim depen del sistema operatiu, de manera que si tinguéssim problemes amb algun
   -- instal·lació de client es podria rebaixar (a costa que el packagesigui una mica més lent).
   k_chunks CONSTANT NUMBER := 1024 * 16;

   -- Nota el màxim teòric és 32K-1 , però depen del sistema operatiu

   --
   -- Declaració de les funcions privades
   --

   /*************************************************************************
      FUNCTION Consultar
      Ejecuta la select y devuelve los registros en un vector.
      param in consulta  : select a ejecutar
      param in out nocopy vector  : afegeix registres al vector.
                                    s'ha d'enviar el vector buit per simular el funcionament que tenia antigament la funció
      return             : 0 si tot correcte, altrament número d'error.
   *************************************************************************/
   -- BUG 9289 - 02/03/2009 - SBG - En pòlisses multirrisc es detecten consultes per sobre
   -- dels 32767 caràcters, obligant a que el paràm. CONSULTA sigui de tipus CLOB.
   FUNCTION consultar(p_tconsulta IN CLOB, p_resultado IN OUT NOCOPY vector)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION JRep
      A partir de la consulta, genera el fitxer CSV del que s'alimentara
      el jreport
   *************************************************************************/
   FUNCTION jrep(pnomfich IN VARCHAR2, pconsulta IN CLOB, pccodplan IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_crea_csv(psproces NUMBER, pcampos VARCHAR2, pcampos2 VARCHAR2, pnomfich VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION Rtf
      Construye el documento rtf a partir de la plantilla, los parámetros que
      se le pasan a la consulta asociada a dicha plantilla, y el nombre del
      fichero de salida.
      param in rutain : Path de lectura (el de la plantilla)
      param in plantilla   : Nombre de la plantilla
      param in rutaout     : Path de escritura (donde grabaremos el resultado)
      param in salida      : Nombre del fichero resultado
      param in registro    : Vector definido en la cabecera del package
      param in subconsulta : No se utiliza
      return               : 0 si ok, <>0 si ko
   *************************************************************************/
   FUNCTION rtf(
      rutain IN VARCHAR2,
      plantilla IN VARCHAR2,
      rutaout IN VARCHAR2,
      salida IN VARCHAR2,
      registro IN vector,
      subconsulta IN vparam)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION XML
      Construye el documento xml a partir de la plantilla, los parámetros que
      se le pasan a la consulta asociada a dicha plantilla, y el nombre del
      fichero de salida.
      param in UTL_FILE.file_type ;  Fitxer al qual afegir-ho
      param in plantilla   : Nombre de la plantilla
   *************************************************************************/
   FUNCTION xml(
      rutain IN VARCHAR2,
      plantilla IN VARCHAR2,
      rutaout IN VARCHAR2,
      salida IN VARCHAR2,
      registro IN vector,
      subconsulta IN vparam)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION XML_STYLES
      Construye el documento xml a partir de la plantilla, los parámetros que
      se le pasan a la consulta asociada a dicha plantilla, y el nombre del
      fichero de salida.
      param in UTL_FILE.file_type ;  Fitxer al qual afegir-ho
      param in plantilla   : Nombre de la plantilla
   *************************************************************************/
   FUNCTION xml_styles(
      rutain IN VARCHAR2,
      plantilla IN VARCHAR2,
      rutaout IN VARCHAR2,
      salida IN VARCHAR2,
      registro IN vector,
      subconsulta IN vparam)
      RETURN NUMBER;

   /*************************************************************************
      PRCEDURE EscriureCLOB
      Afegeix a un fitxer el contingut d'un CLOB
      param in out pFile : UTL_FILE.file_type a afegir-lo
      param in     pText : CLOB
   *************************************************************************/
   PROCEDURE escriureclob(PFILE IN OUT UTL_FILE.file_type, ptext IN CLOB) IS
   BEGIN
      --DBMS_OUTPUT.PUT_LINE( 'E0=>'||substr(pText,-20) );
      --DBMS_OUTPUT.PUT_LINE( 'E1=>'||LENGTH( pText ));
      FOR v_i IN 1 .. CEIL(LENGTH(ptext) / k_chunks) LOOP
         --DBMS_OUTPUT.PUT_LINE('0002=>kk');
         UTL_FILE.put(PFILE, SUBSTR(ptext,(v_i - 1) * k_chunks + 1, k_chunks));
         --DBMS_OUTPUT.PUT_LINE('0002=>kk00');
         UTL_FILE.fflush(PFILE);
      --DBMS_OUTPUT.PUT_LINE('0002=>kk00kk');
      END LOOP;
   END;

   --
   -- Declaració de les funcions públiques
   --

   /*************************************************************************
      FUNCTION f_regparam
      Comodi per inicialitzar el contigut de vparam de manera còmode
   *************************************************************************/
   FUNCTION f_regparam(p_par IN VARCHAR2, p_val IN VARCHAR2)
      RETURN regparam IS
      v_regparam     regparam;
   BEGIN
      v_regparam.par := p_par;
      v_regparam.val := p_val;
      RETURN v_regparam;
   END;

   /*************************************************************************
      FUNCTION Consultar
      Ejecuta la select y devuelve los registros en un vector.
      param in consulta  : select a ejecutar
      param in out nocopy vector  : afegeix registres al vector.
                                    s'ha d'enviar el vector buit per simular el funcionament que tenia antigament la funció
      return             : 0 si tot correcte, altrament número d'error.
   *************************************************************************/
   -- BUG 9289 - 02/03/2009 - SBG - En pòlisses multirrisc es detecten consultes per sobre
   -- dels 32767 caràcters, obligant a que el paràm. P_TCONSULTA sigui de tipus CLOB, i creant
   -- per a tals casos la variable vr_consulta de tipus array.
   FUNCTION consultar(p_tconsulta IN CLOB, p_resultado IN OUT NOCOPY vector)
      RETURN NUMBER IS
      l_thecursor    INTEGER;
      l_columnvalue  VARCHAR2(4000);
      l_desctbl      DBMS_SQL.desc_tab2;
      -- MSR Canviat perquè no falli per nom de columnes de 33 o més caracters
      l_colcnt       NUMBER;
      es_consulta    BOOLEAN;
      vr_consulta    DBMS_SQL.varchar2a;
      v_nlongitud    NUMBER;
      v_index        NUMBER;
      v_nparts       NUMBER;
      -- Utilitzat per indicar tipus de dades a DEFINE_COLUMN.
      -- Sempre li direm que es VARCHAR2 independentment del que realemnt sigui la columna
      -- perquè ens faci la conversió implícita a VARCHAR2 si no ho és.
      k_columndatatype CONSTANT VARCHAR2(32767) := NULL;
      -- En cas que ja tingui dades, les afegirem a p_resultado
      k_primer_index NUMBER := NVL(p_resultado.LAST, 0);
      v_filas_procesadas NUMBER;
      v_pasexec      NUMBER := 0;
   BEGIN
      --DBMS_OUTPUT.PUT_LINE('p_tconsulta=>'||p_tconsulta);
            -- Permetem posar espais, tabuladors, .. sense que ens falli la detecció que és un SELECT
      es_consulta := REGEXP_INSTR(p_tconsulta, '^[[:space:]]*SELECT', modifier => 'i') > 0;
      -- BUG10700 Permetem una longitud indeterminada per la consulta
      v_nlongitud := LENGTH(p_tconsulta);
      v_nparts := 1;
      v_index := 1;
      v_pasexec := 1;

      LOOP
         vr_consulta(v_index) := SUBSTR(p_tconsulta, v_nparts, 32767);
         v_nparts := v_nparts + 32767;
         EXIT WHEN v_nparts > v_nlongitud;
         v_index := v_index + 1;
      END LOOP;

      v_pasexec := 2;
      l_thecursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(l_thecursor, vr_consulta, 1, v_index, FALSE, DBMS_SQL.native);

      IF es_consulta THEN
         -- Obtenim les columnes que torna el SELECT
         DBMS_SQL.describe_columns2(l_thecursor, l_colcnt, l_desctbl);

         FOR i IN 1 .. l_colcnt LOOP
            -- Indiquem que totes les columnes ens les torni com VARCHAR2
            DBMS_SQL.define_column(l_thecursor, i, k_columndatatype, 32767);
            -- Assignem el nom tornat per la columna a la posicó 0 dels resultat
            p_resultado(0)(i) := l_desctbl(i).col_name;
         END LOOP;
      END IF;

      v_pasexec := 3;
      v_filas_procesadas := DBMS_SQL.EXECUTE(l_thecursor);

      IF es_consulta THEN
         -- Per un SELECT recorrem tots els registres i per cada registre desem
         -- el valor de la columna a la variable 'resultado'
         WHILE(DBMS_SQL.fetch_rows(l_thecursor) > 0) LOOP
            FOR i IN 1 .. l_colcnt LOOP
               DBMS_SQL.COLUMN_VALUE(l_thecursor, i, l_columnvalue);
               p_resultado(k_primer_index + DBMS_SQL.last_row_count)(i) := l_columnvalue;
            END LOOP;
         END LOOP;
      END IF;

      v_pasexec := 4;
      DBMS_SQL.close_cursor(l_thecursor);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(l_thecursor) THEN
            DBMS_SQL.close_cursor(l_thecursor);
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.CONSULTAR', v_pasexec, SQLCODE, SQLERRM);
         RAISE;
   END consultar;

   /*************************************************************************
      FUNCTION GenCon
      Construye el documento rtf a partir de la plantilla, los parámetros que
      se le pasan a la consulta asociada a dicha plantilla, y el nombre del
      fichero de salida.
      param in plantilla : Nombre de la plantilla
      param in pusuario  : Nombre del usuario
      param in registro  : Vector de parámetros (nombre + valor)
      param out codimp   : Número secuencia informe
      param in pestado   : Estado
      param in pnomfich  : Nombre del fichero de salida
      return             : 0 si ok, <>0 si ko
   *************************************************************************/
   FUNCTION gencon(
      plantilla IN VARCHAR2,
      pusuario VARCHAR2,
      registro IN vparam,
      codimp OUT NUMBER,
      pestado IN NUMBER DEFAULT 1,
      pnomfich IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      -- Si el estado = 1 entonces general el fichero
      -- Si el estado = 1 genera un fichero temporal con el nombre del usuario y no graba el historico.
      secuencia      informes.sinforme%TYPE;
      multireg       CLOB;
      consulta       CLOB;
      consulta_total CLOB;
      cabecera       CLOB;
      saveconsulta   CLOB;
      valoressql     pac_isql.vector;
      consultasql    pac_isql.vector;
      subconsulta    pac_isql.vector;
      vmsubcon       pac_isql.vparam;
      error          NUMBER;
      filas          NUMBER(4);
      fichero        NUMBER(3);
      informe        VARCHAR2(1000);
      ruta           VARCHAR2(1000);
      rutain         VARCHAR2(1000);
      rutaout        VARCHAR2(1000);
      v_desde        informes.ndesde%TYPE;
      v_hasta        informes.nhasta%TYPE;
      indice         NUMBER(3);
      posicion       NUMBER(15);
      posifin        NUMBER(15);
      alias          VARCHAR2(700);
      primerfrom     NUMBER(15);
      contamul       NUMBER(2);
      contasub       NUMBER(15);
      vpasexec       NUMBER(2) := 0;
      v_idcopia      VARCHAR2(10);
      --
      w_sentencia    CLOB;
      w_cgenpdf      NUMBER;
      --
      w_cgenrep      NUMBER;   --BUG19927 - JTS - 03/11/2011
      w_cidioma      NUMBER;   --BUG19927 - JTS - 03/11/2011
   --
   BEGIN
      BEGIN
         SELECT CASE NVL(c.ctipolob, 0)
                   WHEN 1 THEN cconsultalob
                   ELSE TO_CLOB(c.cconsulta)
                END,
                cp.cgenpdf, cp.cgenrep
           INTO w_sentencia,
                w_cgenpdf, w_cgenrep
           FROM consultas c, codiplantillas cp
          WHERE c.idconsulta = cp.idconsulta
            AND UPPER(cp.ccodplan) = UPPER(plantilla);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.GENCON', vpasexec, SQLCODE, SQLERRM);
            RETURN -1;
      END;

      -- Validem que retorni quelcom a la consulta
      IF w_sentencia IS NULL
         OR LENGTH(w_sentencia) = 0 THEN
         RETURN -1;
      END IF;

      vpasexec := 3;

      -- Antes de cambiar los parametros introducidos en la llamada a gencon
      -- primero cambiamos los que están dados de alta en CODIPARAMETROS
      FOR r IN (SELECT ccodplan, cparametro, valor
                  FROM plantiparametros
                 WHERE UPPER(plantiparametros.ccodplan) = UPPER(plantilla)) LOOP
         w_sentencia := REPLACE(UPPER(w_sentencia), '&' || UPPER(r.cparametro),
                                UPPER(r.valor));
      END LOOP;

      vpasexec := 5;
      -- Sustitución de parámetros a partir del indice 1.
      -- Si este índice ya es nulo no buscamos más parametros.
      indice := registro.FIRST;

      WHILE indice IS NOT NULL LOOP
         EXIT WHEN registro(indice).par IS NULL;
         w_sentencia := REPLACE(UPPER(w_sentencia), '&' || UPPER(registro(indice).par),
                                UPPER(registro(indice).val));

         --BUG19927 obtenemos idioma
         IF UPPER(registro(indice).par) = 'PMT_IDIOMA' THEN
            w_cidioma := registro(indice).val;
         END IF;

         --Fi bug 19927
         indice := registro.NEXT(indice);
      END LOOP;

      BEGIN
         -- BUG 0016033 - 23/09/2010 - JMF: Afegir nvl idioma parinstalación
         -- ja que hi han casos en que no entra loop i no te valor en el idioma.
         SELECT cinforme
           INTO informe
           FROM detplantillas
          WHERE UPPER(detplantillas.ccodplan) = UPPER(plantilla)
            AND detplantillas.cidioma = NVL(w_cidioma,
                                            NVL(pac_isql.rgidioma,
                                                f_parinstalacion_n('IDIOMARTF')));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- No existe la plantilla para el idioma seleccionado
            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.GENCON', vpasexec, SQLCODE, SQLERRM);
            RETURN -49;
      END;

      vpasexec := 7;

      IF w_cgenrep = 0
         AND UPPER(SUBSTR(informe, INSTR(informe, '.', -1) + 1)) != 'CSV' THEN   --BUG19927 si no es JRep seguimos como siempre
         --Hacemos la llamada para que nos devuleva los <n> registros
         --en función de la consulta Seleccionada
         --DBMS_OUTPUT.PUT_LINE('Consultar 1');
         error := pac_isql.consultar(w_sentencia, valoressql);

         IF error <> 0 THEN
            RETURN -2;
         END IF;

         consulta := 'SELECT ';
         vpasexec := 9;

         -- Ahora hacemos los mismo que antes pero añadiendo las formulas
         FOR columnas IN (SELECT   cformato, clabel, NVL(ctipo, 0) ctipo
                              FROM codiformulas c, plantivalores p
                             WHERE c.idformula = p.idformula
                               AND UPPER(ccodplan) = UPPER(plantilla)
                          ORDER BY NVL(ctipo, 0)) LOOP
            IF consulta = 'SELECT ' THEN
               IF columnas.ctipo = 2 THEN
                  consulta := consulta || '''[XLXI]'', ' || columnas.cformato || ' "'
                              || columnas.clabel || '"';
               ELSE
                  consulta := consulta || columnas.cformato || ' "' || columnas.clabel || '"';
               END IF;
            ELSE
               IF columnas.ctipo = 2 THEN
                  consulta := consulta || ',''[XLXI]'', ' || columnas.cformato || ' "'
                              || columnas.clabel || '"';
               ELSE
                  consulta := consulta || ', ' || columnas.cformato || ' "' || columnas.clabel
                              || '"';
               END IF;
            END IF;
         END LOOP;

         saveconsulta := consulta;

         SELECT NVL(MAX(nhasta), 0) + 1
           INTO v_desde
           FROM informes
          WHERE cusuari = pusuario;

         v_hasta := v_desde - 1;
         vpasexec := 11;

         FOR contador IN valoressql.FIRST + 1 .. valoressql.LAST LOOP
            cabecera := NULL;
            v_hasta := v_hasta + 1;

            -- La Columna numero 1 obligatoriamente siempre tiene que ser el idioma.
            -- y se tiene que llamar 'PAR_RTFIDIOMA'
            -- en caso de que no se llame así cogeremos el idioma de IDIOMARTF
            IF UPPER(valoressql(0)(1)) = 'PAR_RTFIDIOMA' THEN
               pac_isql.rgidioma := valoressql(contador)(1);
            ELSE
               pac_isql.rgidioma := f_parinstalacion_n('IDIOMARTF');

               IF pac_isql.rgidioma IS NULL THEN
                  RETURN -50;
               END IF;
            END IF;

            -- Valid per la versió 10g o posterior
            -- Evitem problemes amb literals que tinguin el caràcter '
            FOR v_i IN 1 .. valoressql(0).LAST LOOP
               IF valoressql(0)(v_i) IS NOT NULL THEN
                  consulta := REPLACE(UPPER(consulta), '"' || UPPER(valoressql(0)(v_i)) || '"',
                                      '[XXXXXX]');
                  consulta := REPLACE(UPPER(consulta), ' ' || UPPER(valoressql(0)(v_i)),
                                      CHR(39) || RTRIM(valoressql(contador)(v_i)) || CHR(39));
                  consulta := REPLACE(UPPER(consulta), ',' || UPPER(valoressql(0)(v_i)),
                                      CHR(39) || RTRIM(valoressql(contador)(v_i)) || CHR(39));
                  consulta := REPLACE(UPPER(consulta), '[XXXXXX]',
                                      '"' || UPPER(valoressql(0)(v_i)) || '"');
                  cabecera := cabecera || ',' || CHR(39) || RTRIM(valoressql(contador)(v_i))
                              || CHR(39) || ' "' || UPPER(valoressql(0)(v_i)) || '"';
               END IF;
            END LOOP;

            -- Si consulta es nulo es que no hay formulas
            -- entonces quitamos el primer caracter de la cabecera que es una coma.
            IF consulta = 'SELECT ' THEN
               cabecera := SUBSTR(LTRIM(cabecera), 2);
            END IF;

            consulta := consulta || ' ' || cabecera || ' from dual';
            --DBMS_OUTPUT.PUT_LINE('Consulta:'||consulta);
                       -- ******************* yA TENGO LA CONSULTA *********************++++
                     -- Ahora voy a buscar los multiregistros
                     -- y me encargo de sacar de la consulta la subconsulta multiregistro
                     -- así de colocar el alias de la subconsulta en el interior como
                     -- alias de columna
                     -- para poder ejecutar la select independientemente
            contamul := 1;

            LOOP
               posicion := INSTR(consulta, '''[XLXI]'',');
               EXIT WHEN posicion = 0;
               posifin := INSTR(consulta, '"', posicion, 2);
               multireg := SUBSTR(consulta, posicion + 9, posifin - posicion + 1 - 9);
               consulta := SUBSTR(consulta, 1, posicion - 2) || SUBSTR(consulta, posifin + 1);

               IF SUBSTR(consulta, 1, 8) = 'SELECT ,' THEN
                  consulta := 'SELECT ' || SUBSTR(consulta, 9);
               END IF;

               --   Consulta := SUBSTR(Consulta,1,posicion-9) || SUBSTR(Consulta,posifin+9);
               posicion := posicion + 4;
               --posifin+1;
               alias := SUBSTR(multireg, INSTR(multireg, '"', 1, 1),
                               INSTR(multireg, '"', 1, 2) - INSTR(multireg, '"', 1, 1) + 1);
               primerfrom := INSTR(UPPER(multireg), 'FROM', 1, 1);
               multireg := SUBSTR(multireg, 1, primerfrom - 1) || '"'
                           || SUBSTR(SUBSTR(alias, 2, LENGTH(alias) - 2), 1, 30) || '"'
                           || SUBSTR(multireg, primerfrom);
               multireg := SUBSTR(multireg, 1, INSTR(multireg, '"', 1, 3) - 1);
               -- qUITAMOS los parentesis
               --   Multireg := TRANSLATE ( Multireg,'()','  ');
               vmsubcon(contamul).par := REPLACE(alias, '"', NULL);
               vmsubcon(contamul).val := multireg;
               contamul := contamul + 1;
                           -- Generamos la subconsulta y concatenamos los registros con Enter.
               --DBMS_OUTPUT.PUT_LINE('Consultar 2');
               subconsulta.DELETE;
               error := pac_isql.consultar(multireg, subconsulta);
               multireg := NULL;

               -- Ara ho contruim tenint en compte que podewn passar aquestes coes
               --  1.- La subconsulta no torna absolutament res
               --  2.- La subconsulta ens torna el nom del camp, però cap registre
               IF subconsulta.FIRST IS NOT NULL THEN
                  multireg := ' "' || subconsulta(0)(1) || '"';

                  IF subconsulta.LAST = 0 THEN
                     multireg := 'NULL ' || multireg;
                  ELSE
                     FOR contasub IN 1 .. subconsulta.LAST LOOP
                        IF (contasub = subconsulta.LAST) THEN
                           -- Valid per la versió 10g o posterior
                           -- Evitem problemes amb literals que tinguin el caràcter '
                           multireg := CHR(39) || RTRIM(subconsulta(contasub)(1)) || CHR(39)
                                       || multireg;
                        ELSE
                           multireg := ' || ''\par ' || RTRIM(subconsulta(contasub)(1))
                                       || CHR(39) || multireg;
                        END IF;
                     END LOOP;
                  END IF;
               ELSE
                  multireg := ' null ' || alias;
               END IF;

               IF multireg IS NOT NULL THEN
                  consulta := SUBSTR(consulta, 1, LENGTH(consulta) - 10) || ' ,' || multireg
                              || ' FROM DUAL';
               END IF;
            END LOOP;

            --***************************** fin sección multiregistros ****************************************
            IF consulta_total IS NULL THEN
               consulta_total := consulta;
            ELSE
               consulta_total := consulta_total || ' UNION ALL ' || consulta;
            END IF;

            --DBMS_OUTPUT.PUT_LINE('Consulta total:'||consulta_total);
            vpasexec := 21;
            --DBMS_OUTPUT.PUT_LINE('Consultar 3:'||consulta_total);
            error := pac_isql.consultar(consulta_total, consultasql);
            --DBMS_OUTPUT.PUT_LINE('Consultar 3:'||consultasql.COUNT);
            vpasexec := 23;
            consulta := saveconsulta;
            consulta_total := NULL;
         END LOOP;
      ELSE
         --BUG19927 si es JRep actualizamos la consulta_total y obtenemos el idioma
         consulta_total := w_sentencia;
         pac_isql.rgidioma := w_cidioma;

         SELECT NVL(MAX(nhasta), 0) + 1
           INTO v_desde
           FROM informes
          WHERE cusuari = pusuario;

         v_hasta := v_desde - 1;
      END IF;

      vpasexec := 31;
      -- Buscamos la ruta donde se encuentran las plantillas
      rutain := f_parinstalacion_t('AXISPLANTILLAS');
      --(JAS)04.03.2008 - Integració amb GEDOX. Comprovem si la instal·lació té GEDOX
      --com a sistema de gestió documental. Si és així, generem el document en el
      --directori compartit de GEDOX.
      rutaout := NVL(f_parinstalacion_t('GEDOX_DIR'), f_parinstalacion_t('INFORMES'));
      vpasexec := 33;

      -- Ahora que tenemos el idioma buscamo el fichero asociado a la plantilla
      -- en función del idioma.
      BEGIN
         -- BUG 0016033 - 23/09/2010 - JMF: Afegir nvl idioma parinstalación
         -- ja que hi han casos en que no entra loop i no te valor en el idioma.
         SELECT cinforme
           INTO informe
           FROM detplantillas
          WHERE UPPER(detplantillas.ccodplan) = UPPER(plantilla)
            AND detplantillas.cidioma = NVL(pac_isql.rgidioma, f_parinstalacion_n('IDIOMARTF'));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- No existe la plantilla para el idioma seleccionado
            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.GENCON', vpasexec, SQLCODE, SQLERRM);
            RETURN -49;
      END;

      vpasexec := 35;

      SELECT sinforme.NEXTVAL
        INTO secuencia
        FROM DUAL;

      IF w_cgenrep = 1
         OR UPPER(SUBSTR(informe, INSTR(informe, '.', -1) + 1)) = 'CSV' THEN
         fichero := pac_isql.jrep(pnomfich, consulta_total, plantilla);
      ELSIF UPPER(SUBSTR(informe, INSTR(informe, '.', -1) + 1)) = 'ODT' THEN
         fichero := pac_isql.xml(rutain,
                                 SUBSTR(informe, 1, INSTR(informe, '.', -1) - 1)
                                 || '_content.xml',
                                 rutaout, pnomfich, consultasql, vmsubcon);

         IF fichero = 0 THEN
            fichero := pac_isql.xml_styles(rutain,
                                           SUBSTR(informe, 1, INSTR(informe, '.', -1) - 1)
                                           || '_styles.xml',
                                           rutaout,
                                           SUBSTR(pnomfich, 1,
                                                  INSTR(pnomfich, '_content.xml') - 1)
                                           || '_styles.xml',
                                           consultasql, vmsubcon);
         ELSE
            RETURN fichero;
         END IF;
      ELSE
         IF pestado = 1 THEN
            fichero := pac_isql.rtf(rutain, informe, rutaout, pnomfich, consultasql, vmsubcon);
         ELSE
            fichero := pac_isql.rtf(rutain, informe, rutaout, pnomfich || '-TEMP.rtf',
                                    consultasql, vmsubcon);
         END IF;
      END IF;

      IF fichero <> 0 THEN
         RETURN fichero;
      END IF;

      vpasexec := 37;

      -- Insertamos el registro de control en la tabla INFORMES
      IF pestado = 1 THEN
         INSERT INTO informes
                     (sinforme, cusuari, ccodplan, fsolici, ndesde, nhasta)
              VALUES (secuencia, pusuario, plantilla, f_sysdate, v_desde, v_hasta);

         codimp := secuencia;
         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         DECLARE
            v_consulta     informes_err.error%TYPE;
         BEGIN
            v_consulta := SUBSTR(SQLERRM || CHR(10) || consulta, 1, 3980);

            INSERT INTO informes_err
                        (error)
                 VALUES ('CONSULTA: ' || v_consulta);

            COMMIT;
            p_tab_error(f_sysdate, f_user, 'pac_isql.gencon', vpasexec, SQLCODE,
                        SQLERRM || CHR(10) || DBMS_UTILITY.format_error_backtrace);
         END;

         RETURN -99;
   END gencon;

   /*************************************************************************
      FUNCTION JRep
      A partir de la consulta, genera el fitxer CSV del que s'alimentara
      el jreport
   *************************************************************************/
   FUNCTION jrep(pnomfich IN VARCHAR2, pconsulta IN CLOB, pccodplan IN VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
      smapead        NUMBER;
      cmapead        NUMBER := 450;
      --Map dinamico que genera el fichero CSV
      seq_cons       NUMBER;
      l_colcnt       NUMBER DEFAULT 0;
      l_desctbl      DBMS_SQL.desc_tab;
      l_thecursor    INTEGER DEFAULT DBMS_SQL.open_cursor;
      v_camps        VARCHAR2(32000);
      v_campspar     VARCHAR2(32000);
      v_campspar2    VARCHAR2(32000);
      vpasexec       NUMBER := 0;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DBMS_SQL.parse(l_thecursor, pconsulta, DBMS_SQL.native);
      DBMS_SQL.describe_columns(c => l_thecursor, col_cnt => l_colcnt, desc_t => l_desctbl);

      --Busquem els titols de les columnes de la select
      FOR i IN 1 .. l_colcnt LOOP
         v_camps := v_camps || CHR(39) || LOWER(l_desctbl(i).col_name) || CHR(39) || ',';
      --v_campspar := v_campspar || LOWER(l_desctbl(i).col_name) || '||' || CHR(39) || ';'|| CHR(39) || '||';
      --v_campspar2 := v_campspar2 || LOWER(l_desctbl(i).col_name) || ';';
      END LOOP;

      --v_campspar := RTRIM(v_campspar, '||');
      v_camps := 'SELECT ' || v_camps || CHR(39) || ';' || CHR(39) || ' linea from dual';
      DBMS_SQL.close_cursor(l_thecursor);
      vpasexec := 1;

      SELECT seq_cons_jreps.NEXTVAL
        INTO seq_cons
        FROM DUAL;

      vpasexec := 2;

      --CTipo 1 Noms dels camps
      INSERT INTO consultes_jreports
                  (sproces, ctipo, consulta, ccodplan, cuser, fgenera)
           VALUES (seq_cons, 1, v_camps, pccodplan, f_user, f_sysdate);

      --CTipo 2 Select a generar
      INSERT INTO consultes_jreports
                  (sproces, ctipo, consulta, ccodplan, cuser, fgenera)
           VALUES (seq_cons, 2, pconsulta, pccodplan, f_user, f_sysdate);

      vpasexec := 3;
      COMMIT;
      pac_map.p_genera_parametros_fichero(cmapead, seq_cons, pnomfich || '.csv', 2);
      num_err := pac_map.genera_map(cmapead, smapead);
      --num_err := f_crea_csv(seq_cons, v_campspar, v_campspar2, pnomfich || '.csv');
      vpasexec := 4;
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_isql.jrep', vpasexec, SQLCODE, SQLERRM);
         RETURN 9902619;
   END jrep;

   /*************************************************************************
      FUNCTION Rtf
      Construye el documento rtf a partir de la plantilla, los parámetros que
      se le pasan a la consulta asociada a dicha plantilla, y el nombre del
      fichero de salida.
      param in UTL_FILE.file_type ;  Fitxer al qual afegir-ho
      param in plantilla   : Nombre de la plantilla
   *************************************************************************/
   FUNCTION rtf(
      rutain IN VARCHAR2,
      plantilla IN VARCHAR2,
      rutaout IN VARCHAR2,
      salida IN VARCHAR2,
      registro IN vector,
      subconsulta IN vparam)
      RETURN NUMBER IS
      idin           UTL_FILE.file_type;
      idin_aux       UTL_FILE.file_type;
      idout          UTL_FILE.file_type;
      err            VARCHAR2(200);
      num            NUMBER(8);
      linea          VARCHAR2(32767);
      sublinea       VARCHAR2(32767);
      campo          VARCHAR2(10000);
      trozo          VARCHAR2(10000);
      trozo_aux      VARCHAR2(10000);
      multi          pac_isql.vector;
      longitud       NUMBER(15);
      marca          NUMBER(15);
      --BUG10700-10/07/2009-MSR-Declaració de camps
      v_j            BINARY_INTEGER;
      --v_utilitzar_asseg BOOLEAN;
      v_cap          CLOB;
      v_cos          CLOB;
      v_peu          CLOB;
      v_clob_asseg   CLOB;
      -- Còpies de treball
      v_wcos         CLOB;
   --FI BUG10700-10/07/2009-MSR-Declaració de camps
   BEGIN
      -- Fragmentem la plantilla en les 3 parts que la conforment
      --    Cap:  Cal a l'inicidel document
      --    Cos:  Part a repetir per cada pàgina
      --    Peu:  Cal al final de document
      --BUG10700-10/07/2009-MSR-Obtenció dels fragments que cal tractar
      DECLARE
         v_file         BFILE := BFILENAME(rutain, plantilla);
         -- Agafem el nom del fitxer fins al punt (sense agafar el punt) i hi afegim '_ASSEG.rtf'
         --v_file_asseg   BFILE
                       --:= BFILENAME(rutain, REGEXP_SUBSTR(plantilla, '^[^.]*') || '_ASSEG.rtf');
         v_clob         CLOB;   -- Temporary BLOB
         v_segon_corxet NUMBER;
         v_penultim_corxet NUMBER;
      BEGIN
         --DBMS_OUTPUT.PUT_LINE('B=>'||rutain||':'||plantilla);
         DBMS_LOB.createtemporary(v_clob, TRUE, DBMS_LOB.CALL);
         DBMS_LOB.OPEN(v_file, DBMS_LOB.lob_readonly);
         DBMS_LOB.loadfromfile(v_clob, v_file, DBMS_LOB.lobmaxsize);
         v_segon_corxet := DBMS_LOB.INSTR(v_clob, '{', 1, 2);
                  --v_penultim_corxet := REGEXP_INSTR(v_clob,'}[^}]*}[^}]*$');
         --DBMS_OUTPUT.PUT_LINE('0=>'||v_segon_corxet||':'||v_penultim_corxet||':'||LENGTH(v_clob));
         v_penultim_corxet := INSTR(SUBSTR(v_clob,(DBMS_LOB.getlength(v_clob) - 3000)), '}',
                                    -1, 2);
         v_penultim_corxet := (DBMS_LOB.getlength(v_clob) - 3001) + v_penultim_corxet;
         --DBMS_OUTPUT.PUT_LINE('0=>'||v_segon_corxet||':'||v_penultim_corxet||':'||LENGTH(v_clob));
         v_cap := SUBSTR(v_clob, 1, v_segon_corxet - 1);
         v_cos := SUBSTR(v_clob, v_segon_corxet, v_penultim_corxet - v_segon_corxet + 1);
         v_peu := SUBSTR(v_clob, v_penultim_corxet + 1);
         DBMS_LOB.fileclose(v_file);
         --v_utilitzar_asseg :=(DBMS_LOB.fileexists(v_file_asseg) = 1);

         /*IF v_utilitzar_asseg THEN
            DBMS_LOB.OPEN(v_file_asseg, DBMS_LOB.lob_readonly);
            DBMS_LOB.loadfromfile(v_clob, v_file_asseg, DBMS_LOB.lobmaxsize);
            v_clob_asseg := v_clob;
            DBMS_LOB.fileclose(v_file_asseg);
         END IF;*/
         DBMS_LOB.freetemporary(v_clob);
      EXCEPTION
         WHEN OTHERS THEN
            IF v_clob IS NOT NULL THEN
               DBMS_LOB.freetemporary(v_clob);
            END IF;

            IF DBMS_LOB.fileisopen(v_file) = 1 THEN
               DBMS_LOB.fileclose(v_file);
            END IF;

            -- IF DBMS_LOB.fileisopen(v_file_asseg) = 1 THEN
            --    DBMS_LOB.fileclose(v_file_asseg);
            --END IF;
            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.RTF', 99, SQLCODE, SQLERRM);
            RAISE;
      END;

            -- Si només cal grabar un fitxer l'obrim
           -- IF NOT v_utilitzar_asseg THEN
      --DBMS_OUTPUT.PUT_LINE('0001=>');
      idout := UTL_FILE.fopen(rutaout, salida, 'w', k_chunks);
      escriureclob(idout, v_cap);
      -- END IF;
      v_j := registro.FIRST;

      WHILE v_j IS NOT NULL LOOP
         IF v_j <> 0 THEN   -- Al 0 tenim el títol dels camps
            --DBMS_OUTPUT.PUT_LINE('1=>'||v_j);
                        /*IF v_j >= 1
                           AND v_utilitzar_asseg THEN
                           idout := UTL_FILE.fopen(rutaout, salida || v_j || '.rtf', 'w', k_chunks);
                           v_wcos := v_clob_asseg;
                        ELSE*/
            v_wcos := v_cos;

            --END IF;
            IF v_j > 1
                      --   AND NOT v_utilitzar_asseg
            THEN
               --DBMS_OUTPUT.PUT_LINE('2=>');
               escriureclob(idout, ' \page ');   -- Afegim el salt de pàgina
            END IF;

            FOR v_i IN 1 .. registro(0).LAST LOOP
               EXIT WHEN INSTR(linea, '\{CAMPO.') = 0;

               IF registro(0)(v_i) IS NOT NULL THEN
                  v_wcos := REPLACE(v_wcos, '\{CAMPO.' || UPPER(registro(0)(v_i)) || '\}',
                                    registro(v_j)(v_i));
               END IF;
            END LOOP;

            --DBMS_OUTPUT.PUT_LINE('3=>');
            escriureclob(idout, v_wcos);
                    /* IF v_utilitzar_asseg THEN
                        IF v_j = 1 THEN
         --DBMS_OUTPUT.PUT_LINE('4=>');
                           escriureclob(idout, v_peu);
                        END IF;

                        UTL_FILE.fclose(idout);
                     END IF;*/
         END IF;

         v_j := registro.NEXT(v_j);
      END LOOP;

            --IF NOT v_utilitzar_asseg THEN
      --DBMS_OUTPUT.PUT_LINE('5=>'||SUBSTR(v_peu,-20));
      escriureclob(idout, v_peu);
      UTL_FILE.fclose(idout);
      --END IF;

      --DBMS_OUTPUT.PUT_LINE('6=>');
      --FI BUG10700-10/07/2009-MSR-Obtenció dels fragments que cal tractar
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF UTL_FILE.is_open(idin) THEN
            UTL_FILE.fclose(idin);
         END IF;

         IF UTL_FILE.is_open(idout) THEN
            UTL_FILE.fclose(idout);
         END IF;

         RETURN -1;
      WHEN UTL_FILE.invalid_path THEN
         IF UTL_FILE.is_open(idin) THEN
            UTL_FILE.fclose(idin);
         END IF;

         IF UTL_FILE.is_open(idout) THEN
            UTL_FILE.fclose(idout);
         END IF;

         RETURN -2;
      WHEN UTL_FILE.read_error THEN
         IF UTL_FILE.is_open(idin) THEN
            UTL_FILE.fclose(idin);
         END IF;

         IF UTL_FILE.is_open(idout) THEN
            UTL_FILE.fclose(idout);
         END IF;

         RETURN -3;
      WHEN UTL_FILE.write_error THEN
         IF UTL_FILE.is_open(idin) THEN
            UTL_FILE.fclose(idin);
         END IF;

         IF UTL_FILE.is_open(idout) THEN
            UTL_FILE.fclose(idout);
         END IF;

         RETURN -4;
      WHEN OTHERS THEN
         err := SQLERRM;
         num := SQLCODE;

         IF UTL_FILE.is_open(idin) THEN
            UTL_FILE.fclose(idin);
         END IF;

         IF UTL_FILE.is_open(idout) THEN
            UTL_FILE.fclose(idout);
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.RTF', 99, SQLCODE, SQLERRM);
         RETURN -5;
   END rtf;

   /*************************************************************************
      FUNCTION XML
      Construye el documento xml a partir de la plantilla, los parámetros que
      se le pasan a la consulta asociada a dicha plantilla, y el nombre del
      fichero de salida.
      param in UTL_FILE.file_type ;  Fitxer al qual afegir-ho
      param in plantilla   : Nombre de la plantilla
   *************************************************************************/
   FUNCTION xml(
      rutain IN VARCHAR2,
      plantilla IN VARCHAR2,
      rutaout IN VARCHAR2,
      salida IN VARCHAR2,
      registro IN vector,
      subconsulta IN vparam)
      RETURN NUMBER IS
      idin           UTL_FILE.file_type;
      idin_aux       UTL_FILE.file_type;
      idout          UTL_FILE.file_type;
      err            VARCHAR2(200);
      num            NUMBER(8);
      linea          VARCHAR2(32767);
      sublinea       VARCHAR2(32767);
      campo          VARCHAR2(10000);
      trozo          VARCHAR2(10000);
      trozo_aux      VARCHAR2(10000);
      multi          pac_isql.vector;
      longitud       NUMBER(15);
      marca          NUMBER(15);
      v_j            BINARY_INTEGER;
      v_cap          CLOB;
      v_cos          CLOB;
      v_peu          CLOB;
      v_clob_asseg   CLOB;
      -- Còpies de treball
      v_wcos         CLOB;
   BEGIN
      -- Fragmentem la plantilla en les 3 parts que la conforment
      --    Cap:  Cal a l'inicidel document
      --    Cos:  Part a repetir per cada pàgina
      --    Peu:  Cal al final de document
      DECLARE
         v_file         BFILE := BFILENAME(rutain, plantilla);
         v_clob         CLOB;   -- Temporary BLOB
         v_segon_corxet NUMBER;
         v_penultim_corxet NUMBER;
      BEGIN
         DBMS_LOB.createtemporary(v_clob, TRUE, DBMS_LOB.CALL);
         DBMS_LOB.OPEN(v_file, DBMS_LOB.lob_readonly);
         DBMS_LOB.loadfromfile(v_clob, v_file, DBMS_LOB.lobmaxsize);
         --obtenim a on acaba el tag que marca el començament del cos del fitxer
         v_segon_corxet := DBMS_LOB.INSTR(v_clob, '<office:text', 1, 1);
         v_segon_corxet := DBMS_LOB.INSTR(v_clob, '>', v_segon_corxet, 1);
         --obtenim a on comença el tag que marca el final del cos del fitxer
         v_penultim_corxet := DBMS_LOB.INSTR(v_clob, '</office:text', 1, 1);
         v_cap := SUBSTR(v_clob, 1, v_segon_corxet);
         v_cos := SUBSTR(v_clob, v_segon_corxet + 1, v_penultim_corxet - v_segon_corxet - 1);
         v_peu := SUBSTR(v_clob, v_penultim_corxet);
         DBMS_LOB.fileclose(v_file);
         DBMS_LOB.freetemporary(v_clob);
      EXCEPTION
         WHEN OTHERS THEN
            IF v_clob IS NOT NULL THEN
               DBMS_LOB.freetemporary(v_clob);
            END IF;

            IF DBMS_LOB.fileisopen(v_file) = 1 THEN
               DBMS_LOB.fileclose(v_file);
            END IF;

            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.XML', 99, SQLCODE, SQLERRM);
            RAISE;
      END;

      idout := UTL_FILE.fopen(rutaout, salida, 'w', k_chunks);
      escriureclob(idout, v_cap);
      v_j := registro.FIRST;

      WHILE v_j IS NOT NULL LOOP
         IF v_j <> 0 THEN   -- Al 0 tenim el títol dels camps
            v_wcos := v_cos;

                        --Aixo no cal en xml :D
                        /*IF v_j > 1
                        THEN
            --DBMS_OUTPUT.PUT_LINE('2=>');
                           escriureclob(idout, ' \page ');   -- Afegim el salt de pàgina
                        END IF;*/
                        --
            FOR v_i IN 1 .. registro(0).LAST LOOP
               EXIT WHEN INSTR(linea, '{CAMPO.') = 0;

               IF registro(0)(v_i) IS NOT NULL THEN
                  --BUG 14821 - JTS - 02/06/2010
                  v_wcos :=
                     REPLACE
                        (v_wcos, '{CAMPO.' || UPPER(registro(0)(v_i)) || '}',
                         CONVERT
                            (REPLACE
                                (REPLACE
                                    (REPLACE
                                        (REPLACE
                                            (REPLACE
                                                (REPLACE
                                                       (REPLACE(REPLACE(registro(v_j)(v_i),
                                                                        '&', '&' || 'amp;'),
                                                                '>', '&' || 'gt;'),
                                                        '<', '&' || 'lt;'),
                                                 '´', '&' || 'apos;'),
                                             '\par ', '<text:line-break/>'),
                                         '\par', ''),
                                     '&' || 'lt;!--', '<!--'),
                                 '--&' || 'gt;', '-->'),
                             'UTF8'));
               --Fi BUG 14821
               END IF;
            END LOOP;

            escriureclob(idout, v_wcos);
         END IF;

         v_j := registro.NEXT(v_j);
      END LOOP;

      escriureclob(idout, v_peu);
      UTL_FILE.fclose(idout);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         err := SQLERRM;
         num := SQLCODE;

         IF UTL_FILE.is_open(idin) THEN
            UTL_FILE.fclose(idin);
         END IF;

         IF UTL_FILE.is_open(idout) THEN
            UTL_FILE.fclose(idout);
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.XML', 99, SQLCODE, SQLERRM);
         RETURN 1;
   END xml;

   /*************************************************************************
     FUNCTION XML_STYLES
     Construye el documento xml a partir de la plantilla, los parámetros que
     se le pasan a la consulta asociada a dicha plantilla, y el nombre del
     fichero de salida.
     param in UTL_FILE.file_type ;  Fitxer al qual afegir-ho
     param in plantilla   : Nombre de la plantilla
   *************************************************************************/
   FUNCTION xml_styles(
      rutain IN VARCHAR2,
      plantilla IN VARCHAR2,
      rutaout IN VARCHAR2,
      salida IN VARCHAR2,
      registro IN vector,
      subconsulta IN vparam)
      RETURN NUMBER IS
      idin           UTL_FILE.file_type;
      idin_aux       UTL_FILE.file_type;
      idout          UTL_FILE.file_type;
      err            VARCHAR2(200);
      num            NUMBER(8);
      linea          VARCHAR2(32767);
      sublinea       VARCHAR2(32767);
      campo          VARCHAR2(10000);
      trozo          VARCHAR2(10000);
      trozo_aux      VARCHAR2(10000);
      multi          pac_isql.vector;
      longitud       NUMBER(15);
      marca          NUMBER(15);
      v_j            BINARY_INTEGER;
      v_cos          CLOB;
      v_wcos         CLOB;
      v_file         BFILE := BFILENAME(rutain, plantilla);
   BEGIN
      /*-- Fragmentem la plantilla en les 3 parts que la conforment
      --    Cap:  Cal a l'inicidel document
      --    Cos:  Part a repetir per cada pàgina
      --    Peu:  Cal al final de document
      DECLARE
         v_file         BFILE := BFILENAME(rutain, plantilla);
         v_clob         CLOB;   -- Temporary BLOB
         v_segon_corxet NUMBER;
         v_penultim_corxet NUMBER;
      BEGIN
         DBMS_LOB.createtemporary(v_clob, TRUE, DBMS_LOB.CALL);
         DBMS_LOB.OPEN(v_file, DBMS_LOB.lob_readonly);
         DBMS_LOB.loadfromfile(v_clob, v_file, DBMS_LOB.lobmaxsize);
         --obtenim a on acaba el tag que marca el començament del cos del fitxer
         v_segon_corxet := DBMS_LOB.INSTR(v_clob, '<office:text', 1, 1);
         v_segon_corxet := DBMS_LOB.INSTR(v_clob, '>', v_segon_corxet, 1);
         --obtenim a on comença el tag que marca el final del cos del fitxer
         v_penultim_corxet := DBMS_LOB.INSTR(v_clob, '</office:text', 1, 1);
         v_cap := SUBSTR(v_clob, 1, v_segon_corxet);
         v_cos := SUBSTR(v_clob, v_segon_corxet + 1, v_penultim_corxet - v_segon_corxet - 1);
         v_peu := SUBSTR(v_clob, v_penultim_corxet);
         DBMS_LOB.fileclose(v_file);
         DBMS_LOB.freetemporary(v_clob);
      EXCEPTION
         WHEN OTHERS THEN
            IF v_clob IS NOT NULL THEN
               DBMS_LOB.freetemporary(v_clob);
            END IF;

            IF DBMS_LOB.fileisopen(v_file) = 1 THEN
               DBMS_LOB.fileclose(v_file);
            END IF;

            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.XML', 99, SQLCODE, SQLERRM);
            RAISE;
      END;*/
      BEGIN
         --p_tab_error(f_sysdate, f_user, 'JTS gencon', 2, 'STYLES ENTRO', '');
         DBMS_LOB.createtemporary(v_cos, TRUE, DBMS_LOB.CALL);
         DBMS_LOB.OPEN(v_file, DBMS_LOB.lob_readonly);
         DBMS_LOB.loadfromfile(v_cos, v_file, DBMS_LOB.lobmaxsize);
         DBMS_LOB.fileclose(v_file);
      EXCEPTION
         WHEN DBMS_LOB.operation_failed THEN
            IF v_cos IS NOT NULL THEN
               DBMS_LOB.freetemporary(v_cos);
            END IF;

            IF DBMS_LOB.fileisopen(v_file) = 1 THEN
               DBMS_LOB.fileclose(v_file);
            END IF;

            --p_tab_error(f_sysdate, f_user, 'JTS gencon', 2, 'STYLES PETE1', '');
            RETURN 0;
         WHEN OTHERS THEN
            IF v_cos IS NOT NULL THEN
               DBMS_LOB.freetemporary(v_cos);
            END IF;

            IF DBMS_LOB.fileisopen(v_file) = 1 THEN
               DBMS_LOB.fileclose(v_file);
            END IF;

            --p_tab_error(f_sysdate, f_user, 'JTS gencon', 2, 'STYLES PETE2', '');
            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.XML_STYLES', 1, SQLCODE, SQLERRM);
            RAISE;
      END;

      --
      --p_tab_error(f_sysdate, f_user, 'JTS gencon', 2, 'STYLES fopen', '');
      idout := UTL_FILE.fopen(rutaout, salida, 'w', k_chunks);
      v_j := registro.FIRST;

      WHILE v_j IS NOT NULL LOOP
         --p_tab_error(f_sysdate, f_user, 'JTS gencon', 2, 'STYLES loop', '');
         IF v_j = 1 THEN   -- Al 0 tenim el títol dels camps
            v_wcos := v_cos;

            --
            FOR v_i IN 1 .. registro(0).LAST LOOP
               EXIT WHEN INSTR(linea, '{CAMPO.') = 0;

               IF registro(0)(v_i) IS NOT NULL THEN
                  --BUG 14821 - JTS - 02/06/2010
                  v_wcos :=
                     REPLACE
                        (v_wcos, '{CAMPO.' || UPPER(registro(0)(v_i)) || '}',
                         CONVERT
                            (REPLACE
                                (REPLACE
                                    (REPLACE(REPLACE(REPLACE(REPLACE(registro(v_j)(v_i), '&',
                                                                     '&' || 'amp;'),
                                                             '>', '&' || 'gt;'),
                                                     '<', '&' || 'lt;'),
                                             '´', '&' || 'apos;'),
                                     '\par ', '<text:line-break/>'),
                                 '\par', ''),
                             'UTF8'));
               --Fi BUG 14821
               END IF;
            END LOOP;

            escriureclob(idout, v_wcos);
         END IF;

         v_j := registro.NEXT(v_j);
      END LOOP;

      --p_tab_error(f_sysdate, f_user, 'JTS gencon', 2, 'STYLES fclose', '');
      UTL_FILE.fclose(idout);
      DBMS_LOB.freetemporary(v_cos);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         err := SQLERRM;
         num := SQLCODE;

         IF v_cos IS NOT NULL THEN
            DBMS_LOB.freetemporary(v_cos);
         END IF;

         IF UTL_FILE.is_open(idin) THEN
            UTL_FILE.fclose(idin);
         END IF;

         IF UTL_FILE.is_open(idout) THEN
            UTL_FILE.fclose(idout);
         END IF;

         -- p_tab_error(f_sysdate, f_user, 'JTS gencon', 2, 'STYLES petefinal', '');
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.XML_STYLES', 2, SQLCODE, SQLERRM);
         RETURN 1;
   END xml_styles;

   /*************************************************************************
      FUNCTION JPrevio_GenCon
      Aparentemente, no se utiliza
      param in plantilla : Nombre de la plantilla
      param in pusuario  : Nombre del usuario
      param in registro  : Lista de nombre+valor de param. separados por ';'
      param out codimp   : Número secuencia informe
      param in pestado   : Estado
      return             : 0 si ok, <>0 si ko
   *************************************************************************/
   FUNCTION jprevio_gencon(
      plantilla IN VARCHAR2,
      pusuario VARCHAR2,
      registro IN VARCHAR2,
      codimp OUT NUMBER,
      pestado IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      parametros     vparam;
      posicion_ini   NUMBER(5) := 0;
      posicion_fin   NUMBER(5) := 0;
      cadena         VARCHAR2(32767);
      resultado      NUMBER(5);
      contador       NUMBER(5);
      indice         NUMBER(3);
      informe        VARCHAR2(30);
   BEGIN
      cadena := registro;

      IF registro IS NOT NULL THEN
         cadena := ';' || registro || ';';

         LOOP
            posicion_ini := INSTR(cadena, ';', posicion_fin + 1, 1);
            posicion_fin := INSTR(cadena, ';', posicion_ini + 1, 1);
            EXIT WHEN posicion_ini = 0
                  OR posicion_fin = 0;
            contador := NVL(contador, 0) + 1;

            IF contador MOD 2 = 1 THEN
               indice := NVL(indice, 0) + 1;
               parametros(indice).par := SUBSTR(cadena, posicion_ini + 1,
                                                posicion_fin - posicion_ini - 1);
            ELSE
               parametros(indice).val := SUBSTR(cadena, posicion_ini + 1,
                                                posicion_fin - posicion_ini - 1);
            END IF;

            posicion_fin := posicion_ini;
         END LOOP;
      END IF;

      resultado := pac_isql.gencon(plantilla, pusuario, parametros, codimp, pestado);
      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.jprevio_gencon', 99, SQLCODE, SQLERRM);
         RETURN -33;
   END jprevio_gencon;

   PROCEDURE p_ins_doc_diferida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      psproces IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pctipo IN NUMBER,
      pemail IN VARCHAR2 DEFAULT NULL,
      psubject IN VARCHAR2 DEFAULT NULL) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vsproduc       NUMBER := 0;
      viddocdif      NUMBER;
      vnumerr        NUMBER;
   BEGIN
      --Recuperamos el producto
      --para sproces o cagente utilizaremos el 0
      IF psseguro IS NOT NULL THEN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF pnrecibo IS NOT NULL THEN
         SELECT s.sproduc
           INTO vsproduc
           FROM seguros s, recibos r
          WHERE s.sseguro = r.sseguro
            AND r.nrecibo = pnrecibo;
      END IF;

      IF pnsinies IS NOT NULL THEN
         SELECT s.sproduc
           INTO vsproduc
           FROM seguros s, sin_siniestro SIN
          WHERE s.sseguro = SIN.sseguro
            AND SIN.nsinies = pnsinies;
      END IF;

      IF psidepag IS NOT NULL THEN
         SELECT s.sproduc
           INTO vsproduc
           FROM seguros s, sin_siniestro SIN, sin_tramita_pago stp
          WHERE s.sseguro = SIN.sseguro
            AND SIN.nsinies = stp.nsinies
            AND stp.sidepag = psidepag;
      END IF;

      --Insertamos la documetnación diferida a generar
      INSERT INTO doc_diferida
                  (iddocdif, sseguro, nmovimi, nrecibo, nsinies, sidepag, sproces, cagente,
                   cidioma, ctipo, cestado, cuser, fcreacion, email, subject)
         SELECT iddocdif_seq.NEXTVAL, psseguro, pnmovimi, pnrecibo, pnsinies, psidepag,
                psproces, pcagente, pcidioma, pctipo, 1, f_user, f_sysdate, pemail, psubject
           FROM DUAL;

      SELECT iddocdif_seq.CURRVAL
        INTO viddocdif
        FROM DUAL;

      FOR i IN (SELECT   ROWNUM norden, p.ccodplan, dp.tdescrip, p.ccategoria, p.cdiferido
                    FROM prod_plant_cab p, detplantillas dp
                   WHERE p.sproduc = vsproduc
                     AND p.ctipo = pctipo
                     AND p.ccodplan = dp.ccodplan
                     AND dp.cidioma = NVL(pcidioma,
                                          pac_contexto.f_contextovalorparametro('IAX_IDIOMA'))
                ORDER BY p.ccodplan) LOOP
         INSERT INTO doc_diferida_det
                     (iddocdif, norden, tdescripcion, ccategoria, cdiferido, ccodplan)
              VALUES (viddocdif, i.norden, i.tdescrip, i.ccategoria, i.cdiferido, i.ccodplan);

         IF pemail IS NULL THEN
            vnumerr :=
               pac_isql.f_ins_doc(NULL, i.tdescrip, NULL, pctipo, i.cdiferido, i.ccategoria,
                                  psseguro, pnmovimi, pnrecibo, pnsinies, psidepag, psproces,
                                  pcagente,
                                  NVL(pcidioma,
                                      pac_contexto.f_contextovalorparametro('IAX_IDIOMA')),
                                  viddocdif, i.norden);
         END IF;
      END LOOP;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_ins_doc_diferida', 99, SQLCODE, SQLERRM);
   END p_ins_doc_diferida;

   PROCEDURE p_docs_cartera(
      psproces IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL,
      pncertif IN NUMBER DEFAULT NULL,
      pmes IN NUMBER DEFAULT NULL,
      panyo IN NUMBER DEFAULT NULL) IS
   BEGIN
      IF ((pnpoliza IS NOT NULL
           AND pncertif IS NOT NULL)
          OR psseguro IS NOT NULL) THEN
         IF psseguro IS NOT NULL THEN
            FOR i IN (SELECT   s.sseguro, s.cidioma,
                               pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi, ppc.ctipo
                          FROM prod_plant_cab ppc, carteraaux ca, seguros s
                         WHERE ca.sproces = psproces
                           AND s.npoliza = ca.npoliza
                           AND s.ncertif = ca.ncertif
                           AND s.sseguro = psseguro
                           AND s.sproduc = ppc.sproduc
                           AND ppc.ctipo = 43   --ctipo cartera
                      GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
               pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                           i.cidioma, i.ctipo);
            END LOOP;
         ELSE
            FOR i IN (SELECT   s.sseguro, s.cidioma,
                               pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi, ppc.ctipo
                          FROM prod_plant_cab ppc, carteraaux ca, seguros s
                         WHERE ca.sproces = psproces
                           AND s.npoliza = ca.npoliza
                           AND s.ncertif = ca.ncertif
                           AND s.npoliza = pnpoliza
                           AND s.ncertif = pncertif
                           AND s.sproduc = ppc.sproduc
                           AND ppc.ctipo = 43   --ctipo cartera
                      GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
               pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                           i.cidioma, i.ctipo);
            END LOOP;
         END IF;
      ELSE
         FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro)
                                                                                      nmovimi,
                            ppc.ctipo
                       FROM prod_plant_cab ppc, seguros s
                      WHERE s.sseguro IN(SELECT   sseguro
                                             FROM segcartera
                                            WHERE sproces = psproces
                                              AND TO_CHAR(fcaranu, 'mmyyyy') <=
                                                                     LPAD(pmes, 2, '0')
                                                                     || panyo
                                         GROUP BY sseguro)
                        AND s.sproduc = ppc.sproduc
                        AND ppc.ctipo = 43   --ctipo cartera
                   GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
            pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                        i.cidioma, i.ctipo);
         END LOOP;
      END IF;
   END p_docs_cartera;

   FUNCTION f_ins_doc(
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2,
      ptfich IN VARCHAR2,
      pctipo IN NUMBER,
      pcdiferido IN NUMBER,
      pccategoria IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      psproces IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      piddocdif IN NUMBER,
      pnorden IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vcount_doc     NUMBER := 0;
      vcount_ged     NUMBER := 0;
      viddocimp      NUMBER;
      vestenvio      NUMBER := 0;
   BEGIN
      --Comprobamos los campos clave
      IF ((piddocdif IS NULL
           AND pnorden IS NULL)
          AND(piddocgedox IS NULL)) THEN
         RAISE e_param_error;
      END IF;

      --Comprobamos los campos mandatorios según que campos clave vengan informados
      IF (piddocdif IS NOT NULL
          AND pnorden IS NOT NULL)
         AND(psseguro IS NULL
             AND pnmovimi IS NULL)
         AND pnrecibo IS NULL
         AND pnsinies IS NULL
         AND psidepag IS NULL
         AND psproces IS NULL
         AND pcagente IS NULL THEN
         RAISE e_param_error;
      ELSIF piddocgedox IS NOT NULL
            AND(ptdesc IS NULL
                OR ptfich IS NULL
                OR pctipo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF NVL(pcdiferido, 0) = 0 THEN
         --Si no es diferido, lo borramos
         DELETE FROM docsimpresion
               WHERE iddocgedox = piddocgedox;
      ELSE
         --Comprobamos si ya exite el registro
         IF (piddocdif IS NOT NULL
             AND pnorden IS NOT NULL) THEN
            SELECT COUNT(1)
              INTO vcount_doc
              FROM docsimpresion
             WHERE iddocdif = piddocdif
               AND norden = pnorden;
         END IF;

         IF piddocgedox IS NOT NULL THEN
            SELECT COUNT(1)
              INTO vcount_ged
              FROM docsimpresion
             WHERE iddocgedox = piddocgedox;
         END IF;

         --Updateamos si ya existe el registro
         IF vcount_doc > 0 THEN
            UPDATE docsimpresion
               SET sseguro = NVL(psseguro, sseguro),
                   nmovimi = NVL(pnmovimi, nmovimi),
                   nrecibo = NVL(pnrecibo, nrecibo),
                   nsinies = NVL(pnsinies, nsinies),
                   sidepag = NVL(psidepag, sidepag),
                   sproces = NVL(psproces, sproces),
                   cagente = NVL(pcagente, cagente),
                   cidioma = NVL(pcidioma, cidioma),
                   iddocgedox = NVL(piddocgedox, iddocgedox),
                   tdesc = NVL(ptdesc, tdesc),
                   tfichero = NVL(ptfich, tfichero),
                   ctipo = NVL(pctipo, ctipo),
                   ccategoria = pccategoria,
                   cestado = DECODE(NVL(piddocgedox, iddocgedox), NULL, 3, 0)
             WHERE iddocdif = piddocdif
               AND norden = pnorden;
         ELSIF vcount_ged > 0 THEN
            UPDATE docsimpresion
               SET tdesc = ptdesc,
                   tfichero = ptfich,
                   ctipo = pctipo,
                   ccategoria = pccategoria,
                   sseguro = NVL(psseguro, sseguro),
                   nmovimi = NVL(pnmovimi, nmovimi),
                   nrecibo = NVL(pnrecibo, nrecibo),
                   nsinies = NVL(pnsinies, nsinies),
                   sidepag = NVL(psidepag, sidepag),
                   sproces = NVL(psproces, sproces),
                   cagente = NVL(pcagente, cagente),
                   cidioma = NVL(pcidioma, cidioma),
                   iddocdif = NVL(piddocdif, iddocdif),
                   norden = NVL(pnorden, norden),
                   cestado = 0
             WHERE iddocgedox = piddocgedox;
         ELSE
            IF (pcdiferido = 2) THEN
               vestenvio := 1;
            ELSE
               vestenvio := NULL;
            END IF;

            --Si no existen, es un registro nuevo, se inserta
            SELECT iddocimp_seq.NEXTVAL
              INTO viddocimp
              FROM DUAL;

            INSERT INTO docsimpresion
                        (iddocimp, iddocgedox, tdesc, tfichero, ctipo, ccategoria, cuser,
                         fcrea, cestado, sseguro, nmovimi,
                         nrecibo, nsinies, sidepag, sproces, cagente, cidioma,
                         iddocdif, norden, cdiferido, cestenvio)
                 VALUES (viddocimp, piddocgedox, ptdesc, ptfich, pctipo, pccategoria, f_user,
                         f_sysdate, DECODE(piddocgedox, NULL, 3, 0), psseguro, pnmovimi,
                         pnrecibo, pnsinies, psidepag, psproces, pcagente, pcidioma,
                         piddocdif, pnorden, pcdiferido, vestenvio);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         RETURN 1;
      WHEN OTHERS THEN
         RETURN 1;
   END f_ins_doc;

/*****************************************************************************
Esta funcion recupera aquells documentos configurados para enviarse de forma
diferida. Si el envio ha ido correctamente devuelve 0 en caso contrario 1.
Actualiza el estado del envio  con 2 si se ha enviado correctamente y con
3 si se ha enviado pero ha habido algun tipo de fallo
*****************************************************************************/
   FUNCTION f_envio_documentos
      RETURN NUMBER IS
      TYPE ob_ficheros IS RECORD(
         nombre         VARCHAR2(100),
         fichero        BFILE
      );

      TYPE t_ficheros IS TABLE OF ob_ficheros
         INDEX BY BINARY_INTEGER;

      conn           UTL_SMTP.connection;
      mail_sender    VARCHAR2(1500) := '';
      mail_grc       VARCHAR2(1500) := '';
      mail_cc        VARCHAR2(1500) := '';
      mail_cco       VARCHAR2(1500) := '';
      nerror         NUMBER := 0;
      v_lob          BLOB;
      v_buffer_size  INTEGER := 57;
      v_offset       NUMBER := 1;
      v_raw          RAW(32767);
      v_length       NUMBER := 0;
      vtfilename     VARCHAR2(50);
      vtfilename2    VARCHAR2(50);
      vterror        VARCHAR2(1000);
      ficheros       t_ficheros;
      fichero        ob_ficheros;
      vcount         NUMBER := 0;
      vemail         VARCHAR2(1000) := '';
      vsseguro       NUMBER := 0;
      vsperson       NUMBER := 0;
      vasunto        VARCHAR2(500);
      vcuerpo        VARCHAR2(4000);
      v_pasexec      NUMBER := 0;
      vcontinuar     BOOLEAN := TRUE;
      --
      v_idioma       NUMBER := NVL(pac_contexto.f_contextovalorparametro('IAX_IDIOMA'), 2);
      v_nom          per_detper.tnombre%TYPE;
      v_cognoms      VARCHAR2(300);
      v_nombre       VARCHAR2(500);
      v_nomempresa   VARCHAR2(500);
      errordocs      NUMBER := 0;
      vtexto         VARCHAR2(5500);
   BEGIN
      --Recuperamos inicialmente los datos de configuracion del email, si no se encuentra alguno de ellos fin devuelve 1
      BEGIN
         v_pasexec := 1;

         SELECT men.remitente, desmen.asunto, desmen.cuerpo
           INTO mail_sender, vasunto, vcuerpo
           FROM mensajes_correo men, desmensaje_correo desmen
          WHERE men.scorreo =
                   pac_parametros.f_parempresa_n
                                              (pac_parametros.f_parinstalacion_n('EMPRESADEF'),
                                               'MAIL_ENVIO_DOC')
            AND men.ctipo = 12
            AND men.scorreo = desmen.scorreo
            AND desmen.cidioma = f_usu_idioma;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.f_envio_documentos', v_pasexec, SQLCODE,
                        SQLERRM);
            RETURN 1;
      END;

      v_pasexec := 2;

      FOR j IN (SELECT DISTINCT docs.sseguro, tom.sperson
                           FROM docsimpresion docs, tomadores tom
                          WHERE docs.cdiferido = 2
                            AND docs.cestenvio = 1
                            AND docs.sseguro = tom.sseguro(+)) LOOP
         vsseguro := j.sseguro;
         vsperson := j.sperson;
         vtexto := vcuerpo;
         vcontinuar := TRUE;

         IF (j.sperson IS NULL) THEN
            vemail := NULL;
            nerror := nerror + 1;

            --Debe insertarse el error en la tabla docsimprsion
            UPDATE docsimpresion
               SET cestenvio = 3,
                   testenvio = f_axis_literales(9905468, v_idioma)
             WHERE sseguro = vsseguro
               AND cdiferido = 2
               AND cestenvio = 1;
         ELSE
            -- Recupero el nombre del tomador
            BEGIN
               SELECT REPLACE(p.tnombre, CHR(39), CHR(39) || CHR(39)),
                      REPLACE(DECODE(p.tapelli1, NULL, NULL, p.tapelli1) || ' '
                              || DECODE(p.tapelli2, NULL, NULL, p.tapelli2),
                              CHR(39), CHR(39) || CHR(39))
                 INTO v_nom,
                      v_cognoms
                 FROM per_detper p
                WHERE p.sperson = vsperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_nom := '';
                  v_cognoms := '';
               WHEN OTHERS THEN
                  v_nom := '';
                  v_cognoms := '';
            END;

            v_nombre := v_nom || ' ' || v_cognoms;

            --Reemplazamos el nombre del tomador en el cuerpo del mensajes @nom_tomador#
            IF (LENGTH(vtexto) > 0) THEN
               IF (INSTR(vtexto, '#nom_tomador#', 1) > 0) THEN
                  vtexto := REPLACE(vtexto, '#nom_tomador#', v_nombre);
               END IF;
            END IF;

            --Recupero el email del tomador
            BEGIN
               SELECT p.tvalcon
                 INTO vemail
                 FROM per_contactos p
                WHERE p.sperson = vsperson
                  AND p.cmodcon IN(SELECT MIN(x.cmodcon)
                                     FROM per_contactos x
                                    WHERE x.sperson = vsperson
                                      AND x.ctipcon = 3);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vemail := NULL;
               WHEN OTHERS THEN
                  vemail := NULL;
            END;

            IF vemail IS NULL THEN
               nerror := nerror + 1;

               --Debe insertarse el error en la tabla docsimprsion
               UPDATE docsimpresion
                  SET cestenvio = 3,
                      testenvio = f_axis_literales(9905468, v_idioma)
                WHERE sseguro = vsseguro
                  AND cdiferido = 2
                  AND cestenvio = 1;
            ELSE
               --Recorremos para cada uno de los seguros que tienen documentacion a enviar pendiente los documentos a enviar
               errordocs := 0;

               FOR i IN (SELECT iddocgedox, tfichero
                           FROM docsimpresion
                          WHERE sseguro = vsseguro
                            AND cdiferido = 2
                            AND cestenvio = 1) LOOP
                  pac_axisgedox.verdoc(i.iddocgedox, vtfilename, vterror);

                  IF vterror = 0 THEN
                     vcount := vcount + 1;

                     SELECT SUBSTR(i.tfichero,
                                   GREATEST(INSTR(i.tfichero, '/', -1),
                                            INSTR(i.tfichero, '\', -1))
                                   + 1)
                       INTO vtfilename2
                       FROM DUAL;

                     UTL_FILE.frename('GEDOXTEMPORAL', vtfilename, 'GEDOXTEMPORAL',
                                      vtfilename2, TRUE);
                     fichero := NULL;
                     fichero.nombre := vtfilename2;
                     fichero.fichero := BFILENAME('GEDOXTEMPORAL', vtfilename2);
                     ficheros(vcount) := fichero;
                     v_pasexec := 3;
                  ELSE
                     --Si hay error en buscar el documento
                     UPDATE docsimpresion
                        SET cestenvio = 3,
                            testenvio = 'error en pac_axisgedox.verdoc'
                      WHERE sseguro = vsseguro
                        AND cdiferido = 2
                        AND cestenvio = 1;

                     nerror := nerror + 1;
                     errordocs := 1;
                  END IF;
               END LOOP;

               IF (errordocs = 0) THEN
                  BEGIN
                     conn :=
                        pac_send_mail.begin_mail
                                            (sender => mail_sender, recipients => vemail,
                                             cc => mail_cc, cco => mail_cco,
                                             subject => vasunto,
                                             mime_type => pac_send_mail.multipart_mime_type
                                              || '; charset=iso-8859-1');
                     pac_send_mail.attach_text(conn => conn, DATA => vtexto,
                                               mime_type => 'text/html');
                  EXCEPTION
                     WHEN OTHERS THEN
                        vcount := 0;
                        v_pasexec := 12;
                        vcontinuar := FALSE;
                        p_tab_error(f_sysdate, f_user, 'PAC_ISQL.f_envio_documentos',
                                    v_pasexec, SQLCODE, SQLERRM);

                        --Si el envio no se ha realizado
                        UPDATE docsimpresion
                           SET cestenvio = 3,
                               testenvio = f_axis_literales(9000655, v_idioma)
                         WHERE sseguro = vsseguro
                           AND cdiferido = 2
                           AND cestenvio = 1;

                        nerror := nerror + 1;
                        v_pasexec := 4;
                  END;

                  IF (vcontinuar) THEN
                     FOR i IN 1 .. vcount LOOP
                        v_pasexec := 5;
                        pac_send_mail.begin_attachment(conn => conn, mime_type => 'text/html',
                                                       inline => TRUE,
                                                       filename => ficheros(i).nombre,
                                                       transfer_enc => 'base64');
                        DBMS_LOB.createtemporary(v_lob, FALSE);
                        DBMS_LOB.fileopen(ficheros(i).fichero, DBMS_LOB.file_readonly);
                        DBMS_LOB.loadfromfile(v_lob, ficheros(i).fichero,
                                              DBMS_LOB.getlength(ficheros(i).fichero));
                        v_length := DBMS_LOB.getlength(v_lob);

                        WHILE v_offset < v_length LOOP
                           DBMS_LOB.READ(v_lob, v_buffer_size, v_offset, v_raw);
                           UTL_SMTP.write_raw_data(conn, UTL_ENCODE.base64_encode(v_raw));
                           UTL_SMTP.write_data(conn, UTL_TCP.crlf);
                           v_offset := v_offset + v_buffer_size;
                        END LOOP while_loop;

                        v_offset := 1;
                        v_length := 0;
                        v_buffer_size := 57;
                        v_raw := NULL;
                        v_pasexec := 6;
                        pac_send_mail.end_attachment(conn);
                        v_pasexec := 7;
                        DBMS_LOB.CLOSE(ficheros(i).fichero);
                     END LOOP;

                     BEGIN
                        v_pasexec := 8;
                        pac_send_mail.end_mail(conn => conn);
                        vcount := 0;

                        --Si el envio va correctamente debe actualizarse el registro
                        UPDATE docsimpresion
                           SET cestenvio = 2
                         WHERE sseguro = vsseguro
                           AND cdiferido = 2
                           AND cestenvio = 1;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_pasexec := 12;
                           p_tab_error(f_sysdate, f_user, 'PAC_ISQL.f_envio_documentos',
                                       v_pasexec, SQLCODE, SQLERRM);

                           --Si el envio no se ha realizado
                           UPDATE docsimpresion
                              SET cestenvio = 3,
                                  testenvio = f_axis_literales(9905469, v_idioma)
                            WHERE sseguro = vsseguro
                              AND cdiferido = 2
                              AND cestenvio = 1;

                           nerror := nerror + 1;
                     END;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      COMMIT;

      IF nerror = 0 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.f_envio_documentos', v_pasexec, SQLCODE,
                     SQLERRM);
         ROLLBACK;

         BEGIN
            v_pasexec := 13;
            DBMS_LOB.filecloseall();
         EXCEPTION
            WHEN DBMS_LOB.unopened_file THEN
               p_tab_error(f_sysdate, f_user, 'PAC_ISQL.f_envio_documentos', v_pasexec,
                           SQLCODE, SQLERRM);
               ROLLBACK;
         END;

         RETURN 1;
   END f_envio_documentos;

   FUNCTION f_crea_csv(psproces NUMBER, pcampos VARCHAR2, pcampos2 VARCHAR2, pnomfich VARCHAR2)
      RETURN NUMBER IS
      vcampos        CLOB;
      vcampos2       CLOB;
      vfrom          CLOB;
      num_err        NUMBER;
      vlinia         CLOB;
      vfitxer        CLOB;
      vconsulta      VARCHAR2(32000);

      TYPE r_cursor IS REF CURSOR;

      vr_cursor      r_cursor;
      FILE           UTL_FILE.file_type;
      vpasexec       NUMBER := 0;
      clob_len       INTEGER;
      pos            INTEGER := 1;
      char_buffer    VARCHAR2(32767);
      amount         BINARY_INTEGER := 32760;
      counter        NUMBER := 0;
   BEGIN
      SELECT consulta, consulta
        INTO vcampos, vcampos2
        FROM consultes_jreports
       WHERE sproces = psproces
         AND ctipo = 1;

      vpasexec := 2;

      SELECT consulta
        INTO vfrom
        FROM consultes_jreports
       WHERE sproces = psproces
         AND ctipo = 2;

      vpasexec := 3;
      vfitxer := pcampos2 || CHR(10);
      --
      vconsulta := 'select ' || pcampos || ' linia from (' || vfrom || ')';

      --
      OPEN vr_cursor FOR vconsulta;

      vpasexec := 4;

      LOOP
         FETCH vr_cursor
          INTO vlinia;

         EXIT WHEN vr_cursor%NOTFOUND;
         vfitxer := vfitxer || vlinia || CHR(10);
      END LOOP;

      CLOSE vr_cursor;

      vpasexec := 5;
      clob_len := DBMS_LOB.getlength(vfitxer);
      FILE := UTL_FILE.fopen(pac_md_common.f_get_parinstalacion_t('INFORMES'), pnomfich, 'w',
                             max_linesize => 32767);
      vpasexec := 6;

      WHILE pos < clob_len LOOP
         counter := counter + 1;
         DBMS_LOB.READ(vfitxer, amount, pos, char_buffer);
         UTL_FILE.put(FILE, char_buffer);
         UTL_FILE.fflush(FILE);
         pos := pos + amount;
      END LOOP;

      vpasexec := 7;
      UTL_FILE.fclose(FILE);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.f_crea_csv', vpasexec, SQLCODE, SQLERRM);
         RETURN 1;
   END f_crea_csv;

   --BUG: 34866/202261
   PROCEDURE p_docs_vencimiento(psproces IN NUMBER, psseguro IN NUMBER) IS
   BEGIN
      FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi,
                         ppc.ctipo
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo = (SELECT ctipo
                                        FROM cfg_plantillas_tipos
                                       WHERE ttipo = 'VENCIMIENTOS')
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
         pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                     i.cidioma, i.ctipo);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_docs_vencimiento', 99, SQLCODE, SQLERRM);
   END p_docs_vencimiento;

   --BUG: 0035712/0202997 Ozea
   PROCEDURE p_docs_renovacion(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pemail IN VARCHAR2,
      psubject IN VARCHAR2) IS
   BEGIN
      FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi,
                         ppc.ctipo, s.fcarpro
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo = (SELECT ctipo
                                        FROM cfg_plantillas_tipos
                                       WHERE ttipo = 'RENOVACION')
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo, s.fcarpro) LOOP
         pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                     i.cidioma, i.ctipo, pemail, psubject);

         BEGIN
            INSERT INTO notificaseg
                        (sseguro, ctipo, fecha, fregistra, sproces)
                 VALUES (i.sseguro, i.ctipo, i.fcarpro, f_sysdate, psproces);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      END LOOP;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_docs_vencimiento', 99, SQLCODE, SQLERRM);
   END p_docs_renovacion;

   --BUG 0035712
   PROCEDURE p_docs_vencimiento_add(psproces NUMBER, psseguro IN NUMBER) IS
   BEGIN
      FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi,
                         ppc.ctipo
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo = (SELECT ctipo
                                        FROM cfg_plantillas_tipos
                                       WHERE ttipo = 'VENCIMIENTO_GARAN')
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
         pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                     i.cidioma, i.ctipo);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_docs_vencimiento_add', 99, SQLCODE,
                     SQLERRM);
   END p_docs_vencimiento_add;

   PROCEDURE p_docs_reminder(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pemail IN VARCHAR2 DEFAULT NULL,
      psubject IN VARCHAR2 DEFAULT NULL) IS
   BEGIN
      FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi,
                         ppc.ctipo
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo = (SELECT ctipo
                                        FROM cfg_plantillas_tipos
                                       WHERE ttipo = 'NOTIREC_RECORDATORIO')
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
         pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, pnrecibo, NULL, NULL, NULL, NULL,
                                     i.cidioma, i.ctipo, pemail, psubject);

         BEGIN
            INSERT INTO notificaseg
                        (sseguro, ctipo, fecha, fregistra, sproces, nrecibo)
                 VALUES (i.sseguro, i.ctipo, pfefecto, f_sysdate, psproces, pnrecibo);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      END LOOP;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_docs_reminder', 99, SQLCODE, SQLERRM);
   END p_docs_reminder;

   --BUG 35712/208490
   PROCEDURE p_docs_secondreminder(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pemail IN VARCHAR2 DEFAULT NULL,
      psubject IN VARCHAR2 DEFAULT NULL) IS
   BEGIN
      FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi,
                         ppc.ctipo
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo = (SELECT ctipo
                                        FROM cfg_plantillas_tipos
                                       WHERE ttipo = 'SEGUNDO_RECORDATORIO')
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
         pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, pnrecibo, NULL, NULL, NULL, NULL,
                                     i.cidioma, i.ctipo, pemail, psubject);

         BEGIN
            INSERT INTO notificaseg
                        (sseguro, ctipo, fecha, fregistra, sproces, nrecibo)
                 VALUES (i.sseguro, i.ctipo, pfefecto, f_sysdate, psproces, pnrecibo);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_docs_reminder', 99, SQLCODE, SQLERRM);
   END p_docs_secondreminder;

   PROCEDURE p_docs_finalnotic(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pemail IN VARCHAR2 DEFAULT NULL,
      psubject IN VARCHAR2 DEFAULT NULL) IS
   BEGIN
      FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi,
                         ppc.ctipo
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo = (SELECT ctipo
                                        FROM cfg_plantillas_tipos
                                       WHERE ttipo = 'ULTIMO_RECORDATORIO')
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
         pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, pnrecibo, NULL, NULL, NULL, NULL,
                                     i.cidioma, i.ctipo, pemail, psubject);

         BEGIN
            INSERT INTO notificaseg
                        (sseguro, ctipo, fecha, fregistra, sproces, nrecibo)
                 VALUES (i.sseguro, i.ctipo, pfefecto, f_sysdate, psproces, pnrecibo);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_docs_finalnotic', 99, SQLCODE, SQLERRM);
   END p_docs_finalnotic;

   --INI  --BUG 33632/209101--13/07/2015--ETM
   PROCEDURE p_docs_cancel_letter(psproces NUMBER, psseguro IN NUMBER) IS
   BEGIN
      FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi,
                         ppc.ctipo
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo = (SELECT ctipo
                                        FROM cfg_plantillas_tipos
                                       WHERE ttipo = 'CANCELATION_LETTER')
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
         pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                     i.cidioma, i.ctipo);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_docs_cancel_letter', 99, SQLCODE, SQLERRM);
   END p_docs_cancel_letter;

--FIN  --BUG 33632/209101--13/07/2015--ETM
   PROCEDURE p_docs_vencimiento_letter(psproces IN NUMBER, psseguro IN NUMBER) IS
   BEGIN
      FOR i IN (SELECT   s.sseguro, s.cidioma, pac_isqlfor.f_max_nmovimi(s.sseguro) nmovimi,
                         ppc.ctipo
                    FROM prod_plant_cab ppc, seguros s
                   WHERE s.sseguro = psseguro
                     AND s.sproduc = ppc.sproduc
                     AND ppc.ctipo = (SELECT ctipo
                                        FROM cfg_plantillas_tipos
                                       WHERE ttipo = 'VENCIMIENTO_LETTER')
                GROUP BY s.sseguro, s.cidioma, ppc.ctipo) LOOP
         pac_isql.p_ins_doc_diferida(i.sseguro, i.nmovimi, NULL, NULL, NULL, NULL, NULL,
                                     i.cidioma, i.ctipo);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ISQL.p_docs_vencimiento_letter', 99, SQLCODE,
                     SQLERRM);
   END p_docs_vencimiento_letter;
END pac_isql;

/

  GRANT EXECUTE ON "AXIS"."PAC_ISQL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ISQL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ISQL" TO "PROGRAMADORESCSI";
