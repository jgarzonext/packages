create or replace PACKAGE BODY pac_productos AS
    /******************************************************************************
       NOMBRE:       PAC_PRODUCTOS
       PROPÓSITO: Recupera las consultas del producto

       REVISIONES:
       Ver        Fecha       Autor       Descripción
       ---------  ----------  ---------  ------------------------------------
       1.0                                1. Creación del package.
       2.0        01/04/2009   SBG        2. Creació funció f_get_filtroprod
       3.0        17/04/2009   APD        3. Bug 9699 - primero se ha de buscar para la actividad en concreto
                                          y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
       4.0        15/04/2009   DRA        4. BUG0009661: APR - Tipo de revalorización a nivel de producto
       5.0        28/04/2009   DRA        5. 0009906: APR - Ampliar la parametrització de la revaloració a nivell de garantia
       6.0        22/06/2009   ICV        6. 0009784: IAX - Desarrollo de Rehabilitaciones
       7.0        01/07/2009   JJG/NMM    7. 0010470 - Afegir tractament ctippre = 6.
       8.0        16/12/2009   AMC        8. Bug 11331 - Modificar f_get_filtroprod para el nuevo modelo de siniestros.
       9.0        15/01/2010   NMM        9. 12674: CRE087 - Producto ULK- Eliminar pantalla beneficiarios de wizard de contratación
      10.0        20/01/2010   RSC       10. 7926: APR - Fecha de vencimiento a nivel de garantía
                                             (movemos función PAC_PRODUCTOS.f_vto_garantia --> PAC_SEGUROS.f_vto_garantia)
      11.0        19/02/2010   JMF       11. 0013277 CEM - Filtro productos en rescates
      12.0        03/02/2010   DRA       12. 0012760: CRE200 - Consulta de pólizas: mostrar preguntas automáticas.
      13.0        26/03/2010   DRA       13. 0013866: CEM800 - PPA debe permitir bloquear pero no pignorar
      14.0        10/06/2010   JTS       14. 14438: CEM - Unificación de recibos
      15.0        27/07/2010   DRA       15. 0015504: CRE998 - Nou producte PIAM Autònoms
      16.0        11/08/2010   SMF       16. 0015711: AGA003 - standaritzación del pac_cass
      17.0        15/09/2010   ETM       17. 0015884: CEM - Fe de Vida. Nuevos paquetes PLSQL
      18.0        26/10/2010   DRA       18. 0016471: CRT - Configuracion de visibilidad/contratacion de productos a nivel de perfil
      19.0        14/12/2010   XPL       19. 16799: CRT003 - Alta rapida poliza correduria
      20.0        24/02/2011   ICV       20. 0017718: CCAT003 - Accés a productes en funció de l'operació
      21.0        30/05/2011   ETM       21.0018631: ENSA102- Alta del certificado 0 en Contribución
      22.0        14/11/2011   FAL       22. 0019627: GIP102 - Reunificación de recibos
      23.0        03/01/2012   JMF       23. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
      24.0        06/11/2012   XVM       24. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
      25.0        30/10/2012   MDS       25. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
      16.0        11/02/2013   NMM       26. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
      27.0        29/04/2013   FAL       27. 0026820: Errores en los productos (26/03)
      28.0        21/01/2014   JTT       28. 0026501: Añadir el parametro PMT_NPOLIZA a las preguntas de tipo CONSULTA
      29.0        06/02/2015   AFM       29. 0034461: Productos de Convenios - AFM 02/2015
      30.0        09/12/2015   FAL       30. 0036730: I - Producto Subsidio Individual
   ******************************************************************************/

   /***********************************************************************
      Recupera el código de subtipo de producto
      param in psproduc  : código del producto
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_subtipoprod(psproduc IN NUMBER, vcsubpro OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT csubpro
           INTO vcsubpro
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_SubtipoProd. Error .  SPRODUC = ' || psproduc, SQLERRM);
            RETURN 100537;   --Títol del producte inexistent
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_SubtipoProd. Error .  SPRODUC = ' || psproduc, SQLERRM);
         RETURN 102705;   --Error al llegir la taula PRODUCTOS
   END f_get_subtipoprod;

   /***********************************************************************
      Recupera las duraciones del producto
      param in psproduc  : código del producto
      param out vcduraci : duración del producto
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_tipduracion(psproduc IN NUMBER, vcduraci OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT cduraci
           INTO vcduraci
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_TipoDur. Error .  SPRODUC = ' || psproduc, SQLERRM);
            RETURN 100537;   --Títol del producte inexistent
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_TipoDur. Error .  SPRODUC = ' || psproduc, SQLERRM);
         RETURN 102705;   --Error al llegir la taula PRODUCTOS
   END f_get_tipduracion;

   /***********************************************************************
      Recupera el Tipo de pregunta (detvalores.cvalor = 78)
      param in pcpregun  : código de pregunta
      param out pctippre  : tipo pregunta
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregtippre(pcpregun IN NUMBER, pctippre OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcpregun IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT ctippre
           INTO pctippre
           FROM codipregun
          WHERE cpregun = pcpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_PregTipPre. Error .  CPREGUN = ' || pcpregun, SQLERRM);
            RETURN 1000598;   --Pregunta no existente en la tabla CODIPREGUN
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_PregTipPre. Error .  CPREGUN = ' || pcpregun, SQLERRM);
         RETURN 102038;   --Error al llegir la taula CODIPREGUN
   END f_get_pregtippre;

   /***********************************************************************
      Recupera el Tipo de pregunta Pol
      param in psproduc  : código de producto
      param in pcpregun  : código de pregunta
      param out pctippre  : tipo respuesta
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregunpol(psproduc IN NUMBER, pcpregun IN NUMBER, pcpretip OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcpregun IS NULL
         OR psproduc IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT cpretip
           INTO pcpretip
           FROM pregunpro
          WHERE cpregun = pcpregun
            AND sproduc = psproduc
            AND cnivel = 'P';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_PregunPol. Error .  SPRODUC = ' || psproduc || '; CPREGUN = '
                        || pcpregun,
                        SQLERRM);
            RETURN 1000600;   --Pregunta no existente en la tabla PREGUNPRO
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_PregunPol. Error .  SPRODUC = ' || psproduc || '; CPREGUN = '
                     || pcpregun,
                     SQLERRM);
         RETURN 1000601;   --Error al llegir la taula PREGUNPRO
   END f_get_pregunpol;

   /***********************************************************************
      Recupera el Tipo de pregunta Rie
      param in psproduc  : código de producto
      param in pcpregun  : código de pregunta
      param in pcactivi  : código de actividad
      param out pctippre  : tipo respuesta
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregunrie(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcactivi IN NUMBER,
      pcpretip OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL
         OR pcpregun IS NULL
         OR pcactivi IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT cpretip
           INTO pcpretip
           FROM (SELECT cpretip
                   FROM pregunpro
                  WHERE cpregun = pcpregun
                    AND sproduc = psproduc
                    AND cnivel = 'R'
                 UNION ALL
                 SELECT cpretip
                   FROM pregunproactivi
                  WHERE cpregun = pcpregun
                    AND sproduc = psproduc
                    AND cactivi = pcactivi);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_PregunRie. Error .  SPRODUC = ' || psproduc || '; CPREGUN = '
                        || pcpregun || '; CACTIVI = ' || pcactivi,
                        SQLERRM);
            RETURN 1000602;   --Pregunta no existent
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_PregunRie. Error .  SPRODUC = ' || psproduc || '; CPREGUN = '
                     || pcpregun || '; CACTIVI = ' || pcactivi,
                     SQLERRM);
         RETURN 1000601;   --Error al llegir la taula PREGUNPRO
   END f_get_pregunrie;

   /***********************************************************************
      Recupera el Tipo de pregunta Gar
      param in psproduc  : código de producto
      param in pcpregun  : código de pregunta
      param in pcactivi  : código de actividad
      param in pcgarant  : código de garantia
      param out pctippre  : tipo respuesta
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregungar(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpretip OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL
         OR pcpregun IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
         SELECT cpretip
           INTO pcpretip
           FROM (SELECT Distinct cpretip
                   FROM pregunprogaran
                  WHERE cpregun = pcpregun
                    AND sproduc = psproduc
                    AND cactivi = pcactivi
                    AND cgarant = pcgarant
                 UNION
                 SELECT Distinct cpretip
                   FROM pregunprogaran
                  WHERE cpregun = pcpregun
                    AND sproduc = psproduc
                    AND cactivi = 0
                    AND cgarant = pcgarant
                    AND NOT EXISTS(SELECT Distinct cpretip
                                     FROM pregunprogaran
                                    WHERE cpregun = pcpregun
                                      AND sproduc = psproduc
                                      AND cactivi = pcactivi
                                      AND cgarant = pcgarant));
      -- Bug 9699 - APD - 08/04/2009 - Fin
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_PregunGar. Error .  SPRODUC = ' || psproduc || '; CPREGUN = '
                        || pcpregun || '; CACTIVI = ' || pcactivi || '; CGARANT = '
                        || pcgarant,
                        SQLERRM);
            RETURN 1000602;   --Pregunta no existent
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_PregunGar. Error .  SPRODUC = ' || psproduc || '; CPREGUN = '
                     || pcpregun || '; CACTIVI = ' || pcactivi || '; CGARANT = ' || pcgarant,
                     SQLERRM);
         RETURN 110085;   --Error al llegir la taula PREGUNPROGARAN
   END f_get_pregungar;

   /***********************************************************************
      Recupera el Tipo de pregunta Gar
      param in psclagen  : secuencia de clausula
      param in pcidioma   : código idioma
      param out ptclatit : titulo clausula
      param out ptclatex : texto clausula
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_clausugen(
      psclagen IN NUMBER,
      pcidioma IN NUMBER,
      ptclatit OUT VARCHAR2,
      ptclatex OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psclagen IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT tclatit, tclatex
           INTO ptclatit, ptclatex
           FROM clausugen
          WHERE sclagen = psclagen
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_Clausugen. Error .  SCLAGEN = ' || psclagen, SQLERRM);
            RETURN 1000603;   --Clàusula no existent
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_Clausugen. Error .  SCLAGEN = ' || psclagen || ' PCIDIOMA = '
                     || pcidioma,
                     SQLERRM);
         RETURN 1000604;   --Error al llegir la taula CLAUSUGEN
   END f_get_clausugen;

   /***********************************************************************
      Recupera el valor de la respuesta
      param in psproduc  : código producto
      param in pcpregun  : código pregunta
      param in pcrespue  : código respuesta
      param in pcidioma  : código idioma
      param out ptrespue : valor respuesta
      param in pnpoliza  : numero de poliza
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   -- Bug 0012227 - 18/12/2009 - JMF: Afegir sproduc
   -- BUG26501 - 21/01/2014 - JTT: Afegir pnpoliza
   FUNCTION f_get_pregunrespue(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN NUMBER,
      pcidioma IN NUMBER,
      ptrespue OUT VARCHAR2,
      pnpoliza IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      -- BUG 10470 - 01/07/2009 - JJG - afegir tractament ctippre = 6.i.
      w_ctippre      codipregun.ctippre%TYPE;
      w_tconsulta    codipregun.tconsulta%TYPE;
      w_codi         VARCHAR2(100);
      w_descripcio   VARCHAR2(500);
      cur            sys_refcursor;
      w_pas          PLS_INTEGER := 1;
      -- BUG 10470.f.
   --
   BEGIN
      --Comprovació dels parámetres d'entrada
      -- Bug 0012227 - 18/12/2009 - JMF: Afegir sproduc
      IF pcpregun IS NULL
         OR pcrespue IS NULL
         OR psproduc IS NULL
         OR pcidioma IS NULL THEN
         RETURN(9000505);   -- Faltan parametros
      END IF;

      w_pas := 2;

      -- BUG 10470 - 01/07/2009 - JJG - afegir tractament ctippre = 6.i.
      BEGIN
         w_pas := 3;

         SELECT ctippre, tconsulta
           INTO w_ctippre, w_tconsulta
           FROM codipregun
          WHERE cpregun = pcpregun;

         w_pas := 4;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_PregunRespue. Error .  CPREGUN = ' || pcpregun
                        || '; CRESPUE = ' || pcrespue || '; CIDIOMA = ' || pcidioma
                        || '; SPRODUC=' || psproduc || '; NPOLIZA=' || NVL(pnpoliza, 'NULL'),
                        '<pas:' || TO_CHAR(w_pas) || '>' || SQLERRM);
      END;

      w_pas := 5;

      IF w_ctippre = 6 THEN
         BEGIN
            w_pas := 6;

            -- Solo lo hacemso si la select tiene order by
            IF INSTR(w_tconsulta, 'ORDER') != 0 THEN
               w_tconsulta := SUBSTR(w_tconsulta, 1, INSTR(w_tconsulta, 'ORDER') - 2);
            END IF;

            w_pas := 7;
            w_tconsulta := REPLACE(w_tconsulta, ':PMT_IDIOMA', pac_md_common.f_get_cxtidioma);
            w_pas := 8;
            -- Bug 0012227 - 18/12/2009 - JMF: Afegir sproduc
            w_tconsulta := REPLACE(w_tconsulta, ':PMT_SPRODUC', psproduc);
            -- BUG26501 - 21/01/2014 - JTT: S'afegeix el parametre npoliza
            w_tconsulta := REPLACE(w_tconsulta, ':PMT_NPOLIZA', pnpoliza);
            w_tconsulta := REPLACE(w_tconsulta, ':PMT_CAGENTE', pcagente);
            w_tconsulta := REPLACE(w_tconsulta, ':PMT_CACTIVI', nvl(pac_iax_produccion.poliza.det_poliza.gestion.cactivi,0));
			w_tconsulta := REPLACE(w_tconsulta, ':PMT_SSEGURO', pac_iax_produccion.poliza.det_poliza.sseguro);  -- CJMR IAXIS-4205  2019/07/29
			
			--bartolo herrera 02-05-2019 iaxis-3629
                        
            IF pac_iax_produccion.poliza.det_poliza.riesgos(pac_iax_produccion.poliza.det_poliza.riesgos.first).riespersonal IS NOT NULL THEN

                  w_tconsulta := REPLACE(w_tconsulta, ':PMT_ASEGURADOPER', pac_iax_produccion.poliza.det_poliza.riesgos(pac_iax_produccion.poliza.det_poliza.riesgos.first).riespersonal(
                                      pac_iax_produccion.poliza.det_poliza.riesgos(pac_iax_produccion.poliza.det_poliza.riesgos.first).riespersonal.first).spereal);
			ELSE
				   w_tconsulta := REPLACE(w_tconsulta, ':PMT_ASEGURADOPER', 'sperson');
            END IF;
            
            --bartolo herrera 02-05-2019
           
			
			
			

            OPEN cur FOR w_tconsulta;

            w_pas := 9;

            FETCH cur
             INTO w_codi, w_descripcio;

            w_pas := 10;

            WHILE cur%FOUND LOOP
               IF w_codi = pcrespue THEN
                  w_pas := 11;
                  ptrespue := SUBSTR(w_descripcio, 1, 200);
                  w_pas := 12;
                  RETURN(0);
               END IF;

               w_pas := 13;

               FETCH cur
                INTO w_codi, w_descripcio;
            END LOOP;

            w_pas := 14;

            CLOSE cur;
         END;
      ELSE
         -- BUG 10470.f.
         BEGIN
            w_pas := 15;

            SELECT trespue
              INTO ptrespue
              FROM respuestas
             WHERE cpregun = pcpregun
               AND crespue = pcrespue
               AND cidioma = pcidioma;

            w_pas := 16;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                           'F_Get_PregunRespue. Error .  CPREGUN = ' || pcpregun
                           || '; CRESPUE = ' || pcrespue || '; CIDIOMA = ' || pcidioma
                           || '; SPRODUC=' || psproduc || '; NPOLIZA='
                           || NVL(pnpoliza, 'NULL'),
                           '<pas:' || TO_CHAR(w_pas) || '>' || SQLERRM);
               RETURN(1000605);   -- Clàusula no existent
         END;
      END IF;

      w_pas := 17;
      
     
      
      
      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 3,
                     'F_Get_PregunRespue. Error .  CPREGUN = ' || pcpregun || '; CRESPUE = '
                     || pcrespue || '; CIDIOMA = ' || pcidioma || '; SPRODUC=' || psproduc
                     || '; NPOLIZA=' || NVL(pnpoliza, 'NULL'),
                     '<pas:' || TO_CHAR(w_pas) || '>' || SQLERRM);
         RETURN(1000606);   --Error al llegir la taula RESPUESTAS
   END f_get_pregunrespue;

   /***********************************************************************
      Recupera si tiene respuesta P
      param in psproduc  : código de producto
      param in pcidioma  : código idioma
      param out ncount   : número registros
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_prodtienepregp(psproduc IN NUMBER, pcidioma IN NUMBER, ncount OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT COUNT(*)
           INTO ncount
           FROM pregunpro prepro, preguntas preng
          WHERE prepro.cpregun = preng.cpregun
            AND preng.cidioma = pcidioma
            AND prepro.cnivel = 'P'
            AND prepro.cpretip <> 2
            AND prepro.sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_ProdTienePregP Error .  SPRODUC = ' || psproduc, SQLERRM);
            RETURN 103212;   --Error a l' executar la consulta
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_ProdTienePregP Error .  SPRODUC = ' || psproduc, SQLERRM);
         RETURN 102426;   --Error al llegir la taula PREGUNPRO
   END f_get_prodtienepregp;

   /***********************************************************************
      RRecupera si tiene respuesta R
      param in psproduc  : código de producto
      param in pcactivi  : código de actividad
      param in pcidioma  : código idioma
      param out ncount   : número registros
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_prodtienepregr(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      ncount OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT COUNT(*)
           INTO ncount
           FROM (SELECT preact.cpregun, preng.tpregun, preact.cpretip, preact.npreord,
                        preact.tprefor, preact.cpreobl, preact.cresdef, preact.cofersn,
                        preact.tvalfor, NULL ctabla, NULL cmodo
                   FROM pregunproactivi preact, preguntas preng
                  WHERE preact.cpregun = preng.cpregun
                    AND preng.cidioma = pcidioma
                    AND preact.cactivi = pcactivi
                    AND   --//acc DE MOMENT PER DEFECTE ES LA ACTIVITAT 0 acc
                       preact.cpretip <> 2
                    AND preact.sproduc = psproduc
                 UNION ALL
                 SELECT prepro.cpregun, preng.tpregun, prepro.cpretip, prepro.npreord,
                        prepro.tprefor, prepro.cpreobl, prepro.cresdef, prepro.cofersn,
                        prepro.tvalfor, prepro.ctabla, prepro.cmodo
                   FROM pregunpro prepro, preguntas preng
                  WHERE prepro.cpregun = preng.cpregun
                    AND preng.cidioma = pcidioma
                    AND prepro.cnivel = 'R'
                    AND prepro.cpretip <> 2
                    AND prepro.sproduc = psproduc) ted;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_ProdTienePregR Error .  SPRODUC = ' || psproduc, SQLERRM);
            RETURN 103212;   --Error a l' executar la consulta
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_ProdTienePregR Error .  SPRODUC = ' || psproduc, SQLERRM);
         RETURN 102426;   --Error al llegir la taula PREGUNPRO
   END f_get_prodtienepregr;

   /***********************************************************************
      Recupera si tiene respuesta G
      param in psproduc  : código de producto
      param in pcgarant  : código de garantia
      param in pcidioma  : código idioma
      param out ncount   : número registros
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_prodtienepregg(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcidioma IN NUMBER,
      ncount OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
         SELECT COUNT(*)
           INTO ncount
           FROM pregunprogaran pregar, preguntas preng
          WHERE pregar.cpregun = preng.cpregun
            AND preng.cidioma = pcidioma
            AND pregar.sproduc = psproduc
            AND pregar.cactivi = pcactivi
            AND   -- de monent la activitat es 0
               pregar.cpretip <> 2
            AND pregar.cgarant = pcgarant;

         IF ncount = 0 THEN
            SELECT COUNT(*)
              INTO ncount
              FROM pregunprogaran pregar, preguntas preng
             WHERE pregar.cpregun = preng.cpregun
               AND preng.cidioma = pcidioma
               AND pregar.sproduc = psproduc
               AND pregar.cactivi = 0
               AND pregar.cpretip <> 2
               AND pregar.cgarant = pcgarant
               AND NOT EXISTS(SELECT 1
                                FROM pregunprogaran pregar, preguntas preng
                               WHERE pregar.cpregun = preng.cpregun
                                 AND preng.cidioma = pcidioma
                                 AND pregar.sproduc = psproduc
                                 AND pregar.cactivi = pcactivi
                                 AND pregar.cpretip <> 2
                                 AND pregar.cgarant = pcgarant);
         END IF;
      -- Bug 9699 - APD - 08/04/2009 - Fin
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_ProdTienePregG Error .  SPRODUC = ' || psproduc, SQLERRM);
            RETURN 103212;   --Error a l' executar la consulta
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_ProdTienePregG Error .  SPRODUC = ' || psproduc, SQLERRM);
         RETURN 110085;   --Error al llegir la taula PREGUNTAS
   END f_get_prodtienepregg;

   /***********************************************************************
      Recupera el valor del producto
      param in psproduc  : código de producto
      param out pcrevali :
      param out pprevali :
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_revalprod(psproduc IN NUMBER, pcrevali OUT NUMBER, pprevali OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT crevali, prevali
           INTO pcrevali, pprevali
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_TipoDur. Error .  SPRODUC = ' || psproduc, SQLERRM);
            RETURN 100537;   --Títol del producte inexistent
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'P_RevalProd Error .  SPRODUC = ' || psproduc, SQLERRM);
         RETURN 102705;   --Error al llegir la taula PRODUCTOS
   END f_revalprod;

   /***********************************************************************
      Recupera el valor de garanpro
      param in psproduc  : código de producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out pcrevali : codigo de revaloracion
      param out pprevali : porcentaje de revaloracion
      param out pirevali : importe de revaloracion
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_revalgaranpro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcrevali OUT NUMBER,
      pprevali OUT NUMBER,
      pirevali OUT NUMBER)   -- BUG9906:DRA:28/04/2009
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT crevali, prevali, irevali
           INTO pcrevali, pprevali, pirevali
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT crevali, prevali, irevali
                 INTO pcrevali, pprevali, pirevali
                 FROM garanpro
                WHERE sproduc = psproduc
                  AND cactivi = 0
                  AND cgarant = pcgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                              'F_RevalGar Error .  SPRODUC = ' || psproduc || '; CACTIVI = '
                              || pcactivi || ';  CGARANT = ' || pcgarant,
                              SQLERRM);
                  RETURN 105710;   --Garantía no encontrada en la tabla GARANPRO
            END;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_RevalGar Error .  SPRODUC = ' || psproduc, SQLERRM);
         RETURN 1000607;   --Error al llegir la taula GARANPRO
   END f_revalgaranpro;

   /***********************************************************************
      Recupera la agrupaación del producto bscándola por el SPRODUC (si el
      parám. no es null) o bien por CRAMO, CMODALI, CTIPSEG y CCOLECT.
      param in  p_sproduc : código de producto
      param in  p_cramo   : ramo
      param in  p_cmodali : modalidad
      param in  p_ctipseg : tipo
      param in  p_ccolect : colec.
      param out p_cagrpro : código de agrupación
      return              : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_agrupacio(
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cmodali IN NUMBER DEFAULT NULL,
      p_ctipseg IN NUMBER DEFAULT NULL,
      p_ccolect IN NUMBER DEFAULT NULL,
      p_cagrpro OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF p_sproduc IS NOT NULL THEN
         BEGIN
            SELECT cagrpro
              INTO p_cagrpro
              FROM productos
             WHERE sproduc = p_sproduc;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                           'F_Get_Agrupacio Error .  P_SPRODUC = ' || p_sproduc
                           || '; P_CRAMO = ' || p_cramo || ';  P_CMODALI = ' || p_cmodali
                           || ';  P_CTIPSEG = ' || p_ctipseg || ';  P_CCOLECT = ' || p_ccolect,
                           SQLERRM);
               RETURN 100537;   --Títol del producte inexistent
         END;
      ELSIF p_cramo IS NOT NULL
            AND p_cmodali IS NOT NULL
            AND p_ctipseg IS NOT NULL
            AND p_ccolect IS NOT NULL THEN
         BEGIN
            SELECT cagrpro
              INTO p_cagrpro
              FROM productos
             WHERE cramo = p_cramo
               AND cmodali = p_cmodali
               AND ctipseg = p_ctipseg
               AND ccolect = p_ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                           'F_Get_Agrupacio Error .  P_SPRODUC = ' || p_sproduc
                           || '; P_CRAMO = ' || p_cramo || ';  P_CMODALI = ' || p_cmodali
                           || ';  P_CTIPSEG = ' || p_ctipseg || ';  P_CCOLECT = ' || p_ccolect,
                           SQLERRM);
               RETURN 100537;   --Títol del producte inexistent
         END;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_Agrupacio Error .  P_SPRODUC = ' || p_sproduc || '; P_CRAMO = '
                     || p_cramo || ';  P_CMODALI = ' || p_cmodali || ';  P_CTIPSEG = '
                     || p_ctipseg || ';  P_CCOLECT = ' || p_ccolect,
                     SQLERRM);
         RETURN 102705;   --Error al leer la tabla PRODUCTOS
   END f_get_agrupacio;

   /***********************************************************************
      Recupera el código del producto a partir del código interno del seguro.
      param in  p_sseguro : código interno del seguro
      param out p_sproduc : código del producto asociado a la póliza
      return              : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_sproduc(p_sseguro IN NUMBER, p_sproduc OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF p_sseguro IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT sproduc
           INTO p_sproduc
           FROM seguros
          WHERE sseguro = p_sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_Sproduc Error .  P_SSEGURO = ' || p_sseguro, SQLERRM);
            RETURN 103212;   --Error a l' executar la consulta
      END;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_Sproduc Error .  P_SSEGURO = ' || p_sseguro, SQLERRM);
         RETURN 105841;   --Error en lectura o modificación de SEGUROS
   END f_get_sproduc;

   /***********************************************************************
      Recupera el código del producto a partir su ramo, modalidad, tipo de
      seguro y colectivo.
      param in  cramo      : código del ramo
                cmodali    : código de la modalidad
                ctipseg    : código del tipo de seguro
                ccolect    : código de la colectividad
      param out p_sproduc : código del producto asociado a la póliza
      return              : devuelve el sproduc si todo bien, sino null
   ***********************************************************************/
   FUNCTION f_get_sproduc(pcramo NUMBER, pcmodali NUMBER, pctipseg NUMBER, pccolect NUMBER)
      RETURN NUMBER IS
      vsproduc       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros: CRAMO ' || pcramo || 'CMODALI ' || pcmodali || ' CTIPSEG '
            || pctipseg || ' CCOLECT ' || pccolect;
      vobject        VARCHAR2(200) := 'PAC_productos.F_Get_SProduc';
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcramo IS NULL
         OR pcmodali IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM productos p
          WHERE p.cramo = pcramo
            AND p.cmodali = pcmodali
            AND p.ctipseg = pctipseg
            AND p.ccolect = pccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_Sproduc Error .  vparam = ' || vparam, SQLERRM);
            RETURN 103212;   --Error a l' executar la consulta
      END;

      RETURN vsproduc;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_Sproduc Error .  vparam = ' || vparam, SQLERRM);
         RETURN 102705;   --Error al leer la tabla PRODUCTOS
   END f_get_sproduc;

   -- ini t.7817
   /***********************************************************************
      Recupera el valor del campo CTARPOL d'una pregunta asociada a un
      producto.
      param in  p_cramo   : Ramo
      param in  p_cmodali : Modalidad
      param in  p_ctipseg : Tipo de seguro
      param in  p_ccolect : Colectivo
      param in  p_cpregun : Pregunta
      param out p_ctarpol : indica si se debe tarifar o no con el cambio
                            de valor de esta pregunta.
      return              : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_ctarpol(
      p_cramo IN pregunpro.cramo%TYPE,
      p_cmodali IN pregunpro.cmodali%TYPE,
      p_ctipseg IN pregunpro.ctipseg%TYPE,
      p_ccolect IN pregunpro.ccolect%TYPE,
      p_cpregun IN pregunpro.cpregun%TYPE,
      p_ctarpol OUT pregunpro.ctarpol%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros: P_cramo ' || p_cramo || 'P_cmodali ' || p_cmodali || ' P_ctipseg '
            || p_ctipseg || ' P_ccolect ' || p_ccolect || ' P_cpregun ' || p_cpregun;
      vobject        VARCHAR2(200) := 'PAC_productos.F_Get_ctarpol';
      v_ctarpol      pregunpro.ctarpol%TYPE;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF p_cramo IS NULL
         OR p_cmodali IS NULL
         OR p_ctipseg IS NULL
         OR p_ccolect IS NULL
         OR p_cpregun IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT ctarpol
           INTO p_ctarpol
           FROM pregunpro
          WHERE cpregun = p_cpregun
            AND cmodali = p_cmodali
            AND ccolect = p_ccolect
            AND cramo = p_cramo
            AND ctipseg = p_ctipseg;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'F_Get_ctarpol. Error .  vparam = ' || vparam, SQLERRM);
            RETURN 1000602;   --Pregunta no existent
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_Get_ctarpol. Error .  vparam = ' || vparam, SQLERRM);
         RETURN 1000601;   --Error al llegir la taula PREGUNPRO
   END f_get_ctarpol;

   -- fin t.7817

   /**********************************************************************
     Devuelve 0 si no se tiene acceso a ese producto, y 1 si tiene acceso
    **********************************************************************/
   FUNCTION f_prodagente(
      psproduc IN productos.sproduc%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipo IN NUMBER)
      RETURN NUMBER IS
/************* FUNCION QUE RETORNA VALORES 0- NO, 1- SÍ EN FUNCION DEL TIPO DE PROCESO QUE QUEREMOS  ***********/
/*                       1-IMPRESION                                                                           */
/*                       2-EMISION                                                                             */
/*                       3-CARTERA                                                                             */
/*                       4-ESTUDIOS
                         5-Recibos
                         6-Accesible
/***************************************************************************************************************/
      imprime        NUMBER;
      cartera        NUMBER;
      estudis        NUMBER;
      emite          NUMBER;
      imprecibo      NUMBER;
      accesible      NUMBER;
      -- BUG16471:DRA:26/10/2010:Inici
      vcaccprod      cfg_user.caccprod%TYPE;
      v_cempres      empresas.cempres%TYPE;
      v_error        NUMBER;
      v_imprime_cfg  NUMBER;
      v_cartera_cfg  NUMBER;
      v_estudis_cfg  NUMBER;
      v_emite_cfg    NUMBER;
      v_imprecibo_cfg NUMBER;
      v_accesible_cfg NUMBER;
      -- BUG16471:DRA:26/10/2010:Fi
      v_ret          NUMBER;
   BEGIN
      -- BUG16471:DRA:26/10/2010:Inici
      BEGIN
         SELECT r.cempres
           INTO v_cempres
           FROM productos p, codiram r
          WHERE p.sproduc = psproduc
            AND r.cramo = p.cramo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_cempres := pac_parametros.f_parinstalacion_n('EMPRESADEF');
      END;

      BEGIN
         v_error := pac_cfg.f_get_user_caccprod(f_user, v_cempres, vcaccprod);
      EXCEPTION
         WHEN OTHERS THEN
            vcaccprod := NULL;
      END;

      BEGIN
         v_error := pac_cfg.f_get_caccprod(v_cempres, vcaccprod, psproduc, v_emite_cfg,
                                           v_imprime_cfg, v_estudis_cfg, v_cartera_cfg,
                                           v_imprecibo_cfg, v_accesible_cfg);
      EXCEPTION
         WHEN OTHERS THEN
            v_emite_cfg := NULL;
            v_imprime_cfg := NULL;
            v_estudis_cfg := NULL;
            v_cartera_cfg := NULL;
            v_imprecibo_cfg := NULL;
            v_accesible_cfg := NULL;
      END;

      -- Bug 0025087 - JMF - 17/12/2012
      IF NVL(pac_parametros.f_parproducto_n(psproduc, 'MODALIDADPORMEDIADOR'), 0) = 1 THEN
         v_ret := pac_propio.f_prod_usu_esp(psproduc, pcagente, pctipo);
         RETURN v_ret;
      ELSE
         -- BUG16471:DRA:26/10/2010:Fi
         IF pctipo = 1 THEN
            BEGIN
               SELECT imprimir
                 INTO imprime
                 FROM prod_usu pu, productos p
                WHERE pu.cdelega = pcagente
                  AND p.sproduc = psproduc
                  AND pu.cramo = p.cramo
                  AND pu.cmodali = p.cmodali
                  AND pu.ctipseg = p.ctipseg
                  AND pu.ccolect = p.ccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  imprime := v_imprime_cfg;   -- BUG16471:DRA:26/10/2010
            END;

            RETURN imprime;
         ELSIF pctipo = 2 THEN
            BEGIN
               SELECT emitir
                 INTO emite
                 FROM prod_usu pu, productos p
                WHERE pu.cdelega = pcagente
                  AND p.sproduc = psproduc
                  AND pu.cramo = p.cramo
                  AND pu.cmodali = p.cmodali
                  AND pu.ctipseg = p.ctipseg
                  AND pu.ccolect = p.ccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  emite := v_emite_cfg;   -- BUG16471:DRA:26/10/2010
            END;

            RETURN emite;
         ELSIF pctipo = 3 THEN
            BEGIN
               SELECT cartera
                 INTO cartera
                 FROM prod_usu pu, productos p
                WHERE pu.cdelega = pcagente
                  AND p.sproduc = psproduc
                  AND pu.cramo = p.cramo
                  AND pu.cmodali = p.cmodali
                  AND pu.ctipseg = p.ctipseg
                  AND pu.ccolect = p.ccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  cartera := v_cartera_cfg;   -- BUG16471:DRA:26/10/2010
            END;

            RETURN cartera;
         ELSIF pctipo = 4 THEN
            BEGIN
               SELECT estudis
                 INTO estudis
                 FROM prod_usu pu, productos p
                WHERE pu.cdelega = pcagente
                  AND p.sproduc = psproduc
                  AND pu.cramo = p.cramo
                  AND pu.cmodali = p.cmodali
                  AND pu.ctipseg = p.ctipseg
                  AND pu.ccolect = p.ccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  estudis := v_estudis_cfg;   -- BUG16471:DRA:26/10/2010
            END;

            RETURN estudis;
         ELSIF pctipo = 5 THEN
            BEGIN
               SELECT recibos
                 INTO imprecibo
                 FROM prod_usu pu, productos p
                WHERE pu.cdelega = pcagente
                  AND p.sproduc = psproduc
                  AND pu.cramo = p.cramo
                  AND pu.cmodali = p.cmodali
                  AND pu.ctipseg = p.ctipseg
                  AND pu.ccolect = p.ccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  imprecibo := v_imprecibo_cfg;   -- BUG16471:DRA:26/10/2010
            END;

            RETURN imprecibo;
         --Ini bug.: 17718 - ICV - 24/02/2011
         ELSIF pctipo = 6 THEN
            BEGIN
               SELECT accesible
                 INTO accesible
                 FROM prod_usu pu, productos p
                WHERE pu.cdelega = pcagente
                  AND p.sproduc = psproduc
                  AND pu.cramo = p.cramo
                  AND pu.cmodali = p.cmodali
                  AND pu.ctipseg = p.ctipseg
                  AND pu.ccolect = p.ccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  accesible := v_accesible_cfg;
            END;

            RETURN accesible;
         --Fin bug.: 17718
         END IF;
      END IF;
   END f_prodagente;

   /***********************************************************************
      Recupera si un producto tiene cuestionario de salud
      param in psproduc  : código de producto
      param out pccuesti : indica si tiene cuestionario de salud
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_ccuesti(psproduc IN NUMBER, pccuesti OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros: psproduc ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_productos.f_get_ccuesti(';
   BEGIN
      BEGIN
         SELECT NVL(ccuesti, 0)
           INTO pccuesti
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'f_get_ccuesti. Error .  vparam = ' || vparam, SQLERRM);
            RETURN 104347;   -- Producte no trobat a la taula PRODUCTOS
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                     'f_get_ccuesti Error .  ' || vparam, SQLERRM);
         RETURN 102705;   -- Error al leer de la tabla productos
   END f_get_ccuesti;

   FUNCTION f_get_mesesextra(
      psproduc IN NUMBER,
      pmesesextra OUT VARCHAR2,
      pcmodextra OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT nmesextra, cmodextra
        INTO pmesesextra, pcmodextra
        FROM producto_ren
       WHERE sproduc = psproduc;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN 102705;   -- Error al leer de la tabla productos
   END f_get_mesesextra;

---------------------------------------------------------------------------
-- Funció que retorna els imports dels mesos amb pagues extres.
---------------------------------------------------------------------------
-- 24735.NMM.
   FUNCTION f_get_imesextra(psproduc IN NUMBER, pmesesextra OUT VARCHAR2, pcmodextra OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT imesextra, cmodextra
        INTO pmesesextra, pcmodextra
        FROM producto_ren
       WHERE sproduc = psproduc;

      RETURN(0);
   --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(0);
      WHEN OTHERS THEN
         RETURN(102705);   -- Error en llegir de la taula de productes
   END f_get_imesextra;

--
---------------------------------------------------------------------------
/*************************************************************************
   FUNCTION f_get_pargarantia
   Retorna el valor de cpargar de una garantía
   param in psproduc  : código de producto
   param in pgarant   : código de la garantía
   param out pcvalpar : valor
   param in pcactivi  : codi activitat
   return             : devuelve 0 si todo bien, sino el código del error
*************************************************************************/
   FUNCTION f_get_pargarantia(
      pclave IN VARCHAR2,
      psproduc IN NUMBER,
      pgarant IN NUMBER,
      pcvalpar OUT NUMBER,
      pcactivi IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros: psproduc ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_productos.f_get_pargarantia';
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL
         OR pgarant IS NULL THEN
         RETURN 9000505;   -- Falten paràmetres
      END IF;

      BEGIN
         SELECT f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.cgarant,
                                pclave)
           INTO pcvalpar
           FROM garanpro s
          WHERE s.sproduc = psproduc
            AND s.cgarant = pgarant
            AND s.cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                      s.cgarant, pclave)
                 INTO pcvalpar
                 FROM garanpro s
                WHERE s.sproduc = psproduc
                  AND s.cgarant = pgarant
                  AND s.cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                              'f_get_ccuesti. Error .  vparam = ' || vparam, SQLERRM);
                  RETURN 105710;   --Garantía no encontrada en la tabla GARANPRO
            END;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'f_get_ccuesti. Error .  vparam = ' || vparam, SQLERRM);
         RETURN 1000607;   --Error al llegir la taula GARANPRO
   END f_get_pargarantia;

   /***********************************************************************
      FUNCTION f_control_emision
      Retorna el valor de creteni
      param in psolicit   : número de solicitud
      param out pcreteni  : codi indicador proposta
      return              : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_creteni(psolicit IN NUMBER, pcreteni OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --BUG6936-12022009-XVM
            --Comprovació dels parámetres d'entrada
      IF psolicit IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT creteni
           INTO pcreteni
           FROM productos
          WHERE sproduc = (SELECT sproduc
                             FROM estseguros
                            WHERE sseguro = psolicit);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'f_get_creteni Error .  psolicit = ' || psolicit, SQLERRM);
            RETURN 104347;   -- Producte no trobat a la taula PRODUCTOS
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'f_get_creteni Error .  psolicit = ' || psolicit, SQLERRM);
         RETURN 102705;   -- Error al leer de la tabla productos
   END f_get_creteni;

   /*************************************************************************
      FUNCTION f_control_emision
      Retorna el valor de creteni
      param in psproduc   : código de producto
      param out pcdurmin  : duración mínima
      return              : devuelve 0 si todo bien, sino el código del error
   *************************************************************************/
   FUNCTION f_get_cdurmin(psproduc IN NUMBER, pcdurmin OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --BUG6936-12022009-XVM
            --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      BEGIN
         SELECT cdurmin
           INTO pcdurmin
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                        'f_get_cdurmin Error .  psproduc = ' || psproduc, SQLERRM);
            RETURN 104347;   -- Producte no trobat a la taula PRODUCTOS
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'f_get_cdurmin Error .  psproduc = ' || psproduc, SQLERRM);
         RETURN 102705;   -- Error al leer de la tabla productos
   END f_get_cdurmin;

   -- BUG 9017 - 01/04/2009 - SBG - Creació funció f_get_filtroprod
   -- BUG 9390 - 12/06/2009 - DCT - Añadir nuevo TIPO 'PIGNORACION'
   /***********************************************************************
      Retorna un filtre segons el paràmetre d'entrada
      param in p_tipo    : Tipo de productos requeridos:
                           'TF'         ---> Contratables des de Front-Office
                           'REEMB'      ---> Productos de salud
                           'APOR_EXTRA' ---> Con aportaciones extra
                           'SIMUL'      ---> Que puedan tener simulación
                           'RESCA'      ---> Que puedan tener rescates
                           'SINIS'      ---> Que puedan tener siniestros
                           'PIGNORACION'---> Que pueden ser pignorados
                           'RECUNIF'    ---> Que permiten reunificar recibos
                           null         ---> Todos los productos
      param out p_filtro : Sentencia de filtro
      return             : Devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_filtroprod(
      p_tipo IN VARCHAR2,
      p_filtro OUT VARCHAR2,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      v_cagente      agentes.cagente%TYPE;
   BEGIN
      -- Bug 0013277 - 19/02/2010 - JMF: CEM - Afegir RESCA_SIN
      IF p_tipo = 'TF' THEN
         -- Contractables des de Terminal Financer
         p_filtro := ' p.CTERMFIN=1 and p.CACTIVO = 1 and';
      ELSIF p_tipo = 'REEMB' THEN
         -- Reemborsaments
         -- BUG15504:DRA:27/07/2010:Inici
         p_filtro := ' f_parproductos_v(p.SPRODUC, ''AGR_SALUD'') IS NOT NULL and ';
      -- ' PAC_MDPAR_PRODUCTOS.F_GET_PARPRODUCTO(''AGR_SALUD'', P.SPRODUC) = 1 and';
      -- BUG15504:DRA:27/07/2010:Fi
      ELSIF p_tipo = 'APOR_EXTRA' THEN
         -- Els que tenen aportacions extraordinàries
         p_filtro :=
            ' EXISTS (SELECT 1 FROM GARANPRO G WHERE G.SPRODUC = P.SPRODUC AND F_PARGARANPRO_V(G.CRAMO, G.CMODALI, G.CTIPSEG, G.CCOLECT, G.CACTIVI, G.CGARANT, ''TIPO'') = 4) AND';
      ELSIF p_tipo = 'SIMUL' THEN
         -- Els que tenen simulació
         p_filtro :=
            ' p.CTERMFIN=1 and p.CACTIVO = 1 and PAC_MDPAR_PRODUCTOS.F_GET_PARPRODUCTO(''SIMULACION'', P.SPRODUC) = 1 AND';
      ELSIF p_tipo = 'RESCA' THEN
         -- Els que tenen rescats
         p_filtro :=
            ' EXISTS (SELECT 1 FROM PRODCAUMOTSIN PC WHERE CCAUSIN IN (4, 5) AND PC.SPRODUC = P.SPRODUC) AND';
      ELSIF p_tipo = 'RESCA_SIN' THEN
         -- Els que tenen rescats( model nou sinistres)
         p_filtro :=
            ' EXISTS (SELECT 1 FROM SIN_GAR_CAUSA PC WHERE CCAUSIN IN (4, 5) AND PC.SPRODUC = P.SPRODUC) AND';
      ELSIF p_tipo = 'SINIS' THEN
         -- Els que tenen sinistres
         p_filtro :=
            ' EXISTS (SELECT 1 FROM PRODCAUMOTSIN M, CODICAUSIN C WHERE M.CCAUSIN = C.CCAUSIN AND C.CATRIBU = 7 AND M.SPRODUC = P.SPRODUC) AND';
      ELSIF p_tipo = 'PIGNORACION' THEN
         -- Els que tenen pignoracions
         p_filtro := ' F_PARPRODUCTOS_V(P.SPRODUC, ''PERMITE_PIGNORACION'') <> 0 AND';   -- BUG13866:DRA:26/03/2010
      --Bug.: 9784 - ICV - Se añade un nuevo filtro para rehabilitación
      ELSIF p_tipo = 'PERMITE_REHABILITA' THEN
         p_filtro :=
                   ' pac_parametros.F_PARPRODUCTO_N(P.SPRODUC,''PERMITE_REHABILITA'') = 1 AND';
      -- Bug 11931 - 16/12/2009 - AMC
      ELSIF p_tipo = 'SINIESTRO' THEN
         -- Els que tenen sinistres (nou model)
         p_filtro :=
            ' EXISTS (SELECT 1 FROM SIN_GAR_TRAMITACION SGCM, SIN_GAR_CAUSA SGC WHERE SGCM.SPRODUC = SGC.SPRODUC AND SGCM.SPRODUC = P.SPRODUC) AND';
      -- Bug 13108: - 16/02/2010 - JGM
      ELSIF p_tipo = 'TRASPASO' THEN
         p_filtro :=
                    ' PAC_MDPAR_PRODUCTOS.F_GET_PARPRODUCTO(''TDC234_IN'', P.SPRODUC) = 1 and';
      -- BUG 14438 - JTS - 10/06/2010
      ELSIF p_tipo = 'RECUNIF' THEN
         --p_filtro := ' f_parproductos_v(p.sproduc, ''RECUNIF'') = 1 and';
         p_filtro := ' f_parproductos_v(p.sproduc, ''RECUNIF'') IN (1,3) and';   -- BUG 0019627: GIP102 - Reunificación de recibos - FAL - 10/11/2011
      --bug 15884--ETM-15/09/2010
      ELSIF p_tipo = 'FE_DE_VIDA' THEN
         p_filtro := ' F_PARPRODUCTOS_V(p.sproduc, ''FE_DE_VIDA'') = 1 AND';
      ELSIF p_tipo = '14' THEN   -- BUG 16799 - 14/12/2010- S'afegeix aquest tipus per tal que només surtin els productes de  Nota informativa
         p_filtro := ' F_PARPRODUCTOS_V(p.sproduc, ''NOTA_INFORMATIVA'') = 1 AND';
      --BUG 18631--ETM --30/05/2011
      ELSIF p_tipo = '15' THEN
         p_filtro := ' NVL(F_PARPRODUCTOS_V(p.sproduc, ''ADMITE_CERTIFICADOS''),0) = 1 AND';
      -- Bug 27048/0146352 - APD - 11/06/2013
      ELSIF p_tipo = '16' THEN
         p_filtro := ' NVL(F_PARPRODUCTOS_V(p.sproduc, ''ADMITE_CERTIFICADOS''),0) = 0 AND';
      -- fin Bug 27048/0146352 - APD - 11/06/2013
      ELSIF p_tipo = '12' THEN   --Proyecto genérico
         p_filtro := ' nvl(F_PARPRODUCTOS_V(p.sproduc, ''CSIT_PROP''),0) = 12 AND';
      ELSIF p_tipo = 'PERMITE_PREST' THEN
         -- PERMITE PRESTAMOS
         p_filtro :=
                ' PAC_MDPAR_PRODUCTOS.F_GET_PARPRODUCTO(''PERMITE_PREST'', P.SPRODUC) = 1 AND';
      ELSIF p_tipo = 'SALDAR' THEN   -- BUG 25888 - JLTS - 01/02/2013
         p_filtro := ' PAC_PARAMETROS.F_PARPRODUCTO_N(P.SPRODUC,''PERMITE_SALDAR'') = 1 AND';
      ELSIF p_tipo = 'PRORROGAR' THEN   -- BUG 25888 - JLTS - 01/02/2013
         p_filtro :=
                    ' PAC_PARAMETROS.F_PARPRODUCTO_N(P.SPRODUC,''PERMITE_PRORROGAR'') = 1 AND';
      -- Bug 28224/153119 - 19/09/2013 - AMC
      ELSIF p_tipo = 'SUSPENSION' THEN
         p_filtro := ' F_PARPRODUCTOS_V(P.SPRODUC, ''PERMITE_SUSPENSION'') <> 0 AND';
      -- Bug 34411/220473 - ACL - 01/12/2015
      ELSIF p_tipo = 'IPROVPRY' THEN
         -- Tiene proyecciones de reservas
         p_filtro :=
            ' NVL(pac_parametros.F_PARPRODUCTO_N(P.SPRODUC,''PROYECCIONES_RESERVA''),0) = 1 AND';
      END IF;

      IF p_cagente IS NULL THEN
         v_cagente := pac_md_common.f_get_cxtagente;
      ELSE
         v_cagente := p_cagente;
      END IF;

      p_filtro := p_filtro || ' pac_productos.f_prodagente (p.sproduc,' || v_cagente
                  || ',6)=1 AND ';
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(SQLCODE);
   END f_get_filtroprod;

   -- FINAL BUG 9017 - 01/04/2009 - SBG
   -- FINAL BUG 9390 - 12/06/2009 - DCT - Añadir nuevo TIPO 'PIGNORACION'

   -- BUG9661:DRA:15/04/2009: Inici
   /*************************************************************************
      Recuperar la lista de posibles valores de revalorización por producto
      param in p_sproduc : codigo del producto
      param in p_cidioma : codigo del idioma
      return             : VARCHAR2
   *************************************************************************/
   FUNCTION f_get_tipreval(p_sproduc IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      cur            VARCHAR2(2000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
                                  := 'p_sproduc: ' || p_sproduc || ' p_cidioma: ' || p_cidioma;
      vobject        VARCHAR2(200) := 'PAC_PRODUCTOS.f_get_tipreval';

      CURSOR c_revprod IS
         SELECT crevali
           FROM revaliprod
          WHERE sproduc = p_sproduc;

      r_revprod      c_revprod%ROWTYPE;
   BEGIN
      OPEN c_revprod;

      FETCH c_revprod
       INTO r_revprod;

      IF c_revprod%FOUND THEN
         cur := 'select rp.crevali catribu, dv.tatribu from revaliprod rp, detvalores dv '
                || ' where dv.cvalor = 62 and dv.catribu = rp.crevali and '
                || ' dv.cidioma = ' || p_cidioma || ' and rp.sproduc =' || p_sproduc;
      ELSE
         cur := NULL;
      END IF;

      CLOSE c_revprod;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 102705;   -- Error al leer de la tabla productos
   END f_get_tipreval;

   -- BUG9661:DRA:15/04/2009: Fi

   -- BUG9906:DRA:28/04/2009: Inici
   /*************************************************************************
      Recuperar el tipo de revaloracion que aplica para la garantia
      param in p_sproduc    : codigo del producto
      param in p_cactivi    : codigo de la actividad
      param in p_cgarant    : codigo de la garantia
      param in p_crevalipol : codigo de revaloracion de la poliza
      param in p_prevalipol : porcentaje de revaloracion de la poliza
      param in p_irevalipol : importe de revaloracion de la poliza
      param out p_crevali   : codigo de revaloracion
      param out p_prevali   : porcentaje de revaloracion
      param out p_irevali   : importe de revaloracion
      return                : NUMBER
   *************************************************************************/
   FUNCTION f_get_revalgar(
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      p_cgarant IN NUMBER,
      p_crevalipol IN NUMBER,
      p_prevalipol IN NUMBER,
      p_irevalipol IN NUMBER,
      p_crevali OUT NUMBER,
      p_prevali OUT NUMBER,
      p_irevali OUT NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
         := 'p_sproduc: ' || p_sproduc || ' p_cactivi: ' || p_cactivi || ' p_cgarant: '
            || p_cgarant || ' p_crevalipol: ' || p_crevalipol || ' p_irevalipol: '
            || p_irevalipol;
      vobject        VARCHAR2(200) := 'PAC_PRODUCTOS.f_get_revalgaran';
      v_pargar       NUMBER;
      v_error        NUMBER;
   BEGIN
      v_pargar := pac_parametros.f_pargaranpro_n(p_sproduc, p_cactivi, p_cgarant,
                                                 'MODIF_REVALI');

      IF v_pargar = 1 THEN
         -- Aplicar sempre la revaloració definida a nivell de garantia (garanpro.crevali).
         v_error := pac_productos.f_revalgaranpro(p_sproduc, p_cactivi, p_cgarant, p_crevali,
                                                  p_prevali, p_irevali);

         IF v_error <> 0 THEN
            RETURN v_error;
         END IF;
      ELSIF v_pargar = 2 THEN
         -- Aplicar sempre la revaloració definida a nivell de garantia (garanpro.crevali), sempre i quan la pòlissa revaloritzi (seguros,crevali <> 0)
         IF NVL(p_crevalipol, 0) <> 0 THEN
            v_error := pac_productos.f_revalgaranpro(p_sproduc, p_cactivi, p_cgarant,
                                                     p_crevali, p_prevali, p_irevali);

            IF v_error <> 0 THEN
               RETURN v_error;
            END IF;
         ELSE
            p_crevali := 0;
            p_prevali := 0;
            p_irevali := 0;
         END IF;
      ELSIF v_pargar = 3 THEN
         -- Aplicar sempre la revaloració definida a nivell de pòlissa.
         p_crevali := p_crevalipol;
         p_prevali := p_prevalipol;
         p_irevali := p_irevalipol;
      ELSE
         -- Si no existeix la parametrització retornem error
         RETURN 1000423;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 103275;   -- Error al revalorizar
   END f_get_revalgar;

   -- BUG9906:DRA:28/04/2009: Fi

   /***********************************************************************
      Donat un producte retornem el codi de clàusula per defecte del producte.
      param in  p_sproduc: codi  producte
      return             : codi clàusula
      ***********************************************************************/
   -- BUG 12674.NMM.15/01/2010.i.
   FUNCTION f_get_claubenefi_def(
      p_sproduc IN productos.sproduc%TYPE,
      p_sclaben OUT productos.sclaben%TYPE)
      RETURN NUMBER IS
      pas            NUMBER := 1;
      vparam         VARCHAR2(500) := 'p_sproduc= ' || p_sproduc;
      vobject        VARCHAR2(200) := 'PAC_PRODUCTOS.f_get_claubenefi_def';
   --
   BEGIN
      IF p_sproduc IS NULL THEN
         RETURN(9000505);   -- Faltan parametros
      END IF;

      SELECT sclaben
        INTO p_sclaben   -- clàusula de beneficiari per defecte.
        FROM productos
       WHERE sproduc = p_sproduc;

      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, pas, 'sproduc = ' || p_sproduc, SQLERRM);
         RETURN 102705;   -- Error en llegir taula productes.
   END f_get_claubenefi_def;

-- BUG 12674.NMM.15/01/2010.f.

   -- BUG12760:DRA:03/02/2010:Inici
   /***********************************************************************
      Recupera si la pregunta es visible o no
      param in  p_sproduc  : código de productos
      param in  p_cpregun  : código de pregunta
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregvisible(
      p_sproduc IN productos.sproduc%TYPE,
      p_cpregun IN pregunpro.cpregun%TYPE,
      p_cactivi IN pregunproactivi.cactivi%TYPE DEFAULT 0,   -- BUG 0036730 - FAL - 09/12/2015
      p_cvisible OUT NUMBER)
      RETURN NUMBER IS
      pas            NUMBER := 1;
      vparam         VARCHAR2(500)
                                 := 'p_sproduc= ' || p_sproduc || ', p_cpregun= ' || p_cpregun;
      vobject        VARCHAR2(200) := 'PAC_PRODUCTOS.f_get_pregvisible';
   BEGIN
      BEGIN
         SELECT cvisible
           INTO p_cvisible
           FROM pregunpro
          WHERE sproduc = p_sproduc
            AND cpregun = p_cpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN   -- BUG 0036730 - FAL - 09/12/2015
            SELECT 2   -- siempre visible las preguntas por actividad
              INTO p_cvisible
              FROM pregunproactivi
             WHERE sproduc = p_sproduc
               AND cpregun = p_cpregun
               AND cactivi = p_cactivi;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, pas, vparam, SQLERRM);
         RETURN 1000601;   -- Error en llegir taula PREGUNPRO.
   END f_get_pregvisible;

-- BUG12760:DRA:03/02/2010:Fi

   /***********************************************************************
      16.0        11/08/2010   SMF       16. 0015711: AGA003 - standaritzación del pac_cass
      Recupera si la póliza/ recibo pertenece a una poliza de un producto de salud (basada en F_esahorro
      param in  p_sseguro  : código de productos
      param in  p_nrecibo  : código de pregunta
      return               : devuelve 1 si es salud, en caso contrario 0
   ***********************************************************************/
   FUNCTION f_essalud(p_nrecibo IN recibos.nrecibo%TYPE, p_sseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER IS
      pas            NUMBER := 1;
      vparam         VARCHAR2(500)
                                 := 'p_sproduc= ' || p_nrecibo || ', p_cpregun= ' || p_sseguro;
      vobject        VARCHAR2(200) := 'PAC_PRODUCTOS.f_essalud';
      vsseguro       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcagrpro       NUMBER;
   BEGIN
      IF p_nrecibo IS NULL
         AND p_sseguro IS NULL THEN
         RETURN 101901;   -- PAS INCORRECTE DE PARÀMETRES A LA FUNCIÓ
      ELSE   -- PARÀMETRES CORRECTES
         IF p_sseguro IS NULL THEN
            BEGIN
               SELECT sseguro
                 INTO vsseguro
                 FROM recibos
                WHERE nrecibo = p_nrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 101902;   -- REBUT NO TROBAT A LA TAULA RECIBOS
               WHEN OTHERS THEN
                  RETURN 102367;   -- ERROR AL LLEGIR DE RECIBOS
            END;
         ELSE
            vsseguro := p_sseguro;
         END IF;

         BEGIN
            SELECT cramo, cmodali, ctipseg, ccolect
              INTO vcramo, vcmodali, vctipseg, vccolect
              FROM seguros
             WHERE sseguro = vsseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 101903;   -- ASSEGURANÇA NO TROBADA A SEGUROS
            WHEN OTHERS THEN
               RETURN 101919;   -- ERROR AL LLEGIR DE SEGUROS
         END;

         BEGIN
            SELECT cagrpro
              INTO vcagrpro
              FROM productos
             WHERE cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104347;   -- PRODUCTE NO TROBAT A PRODUCTOS
            WHEN OTHERS THEN
               RETURN 102705;   -- ERROR AL LLEGIR DE PRODUCTOS
         END;

         IF vcagrpro = 5 THEN
            RETURN 1;   -- ES DE SALUD
         ELSE
            RETURN 0;   -- POS NO
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, pas, vparam, SQLERRM);
         RETURN 1000601;   -- Error en llegir taula PREGUNPRO.
   END f_essalud;

--16.0        11/08/2010   SMF       16. 0015711: AGA003 - standaritzación del pac_cass

   -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
   /***********************************************************************
      Recupera el valor de garanpro
      param in psproduc  : código de producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out pcderreg : código de si aplica derechos de registro
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_derreggaranpro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcderreg OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RETURN 9000505;   -- Faltan parametros
      END IF;

      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT cderreg
           INTO pcderreg
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT cderreg
                 INTO pcderreg
                 FROM garanpro
                WHERE sproduc = psproduc
                  AND cactivi = 0
                  AND cgarant = pcgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 1,
                              'F_derreggaranpro Error .  SPRODUC = ' || psproduc
                              || '; CACTIVI = ' || pcactivi || ';  CGARANT = ' || pcgarant,
                              SQLERRM);
                  RETURN 105710;   --Garantía no encontrada en la tabla GARANPRO
            END;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRODUCTOS', 2,
                     'F_derreggaranpro Error .  SPRODUC = ' || psproduc, SQLERRM);
         RETURN 1000607;   --Error al llegir la taula GARANPRO
   END f_derreggaranpro;

-- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia

   -- BUG 0020671 - 03/01/2012 - JMF
   /***********************************************************************
      Recupera si la pregunta es visible o no
      param in  p_sproduc  : código de productos
      param in  p_cpregun  : código de pregunta
      param in  p_cactivi  : código de actividad
      param in  p_cgarant  : código de garantia
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregunprogaranvisible(
      p_sproduc IN NUMBER,
      p_cpregun IN NUMBER,
      p_cactivi IN NUMBER,
      p_cgarant IN NUMBER,
      p_cvisible OUT NUMBER)
      RETURN NUMBER IS
      pas            NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'pro=' || p_sproduc || ' pre=' || p_cpregun || ' act=' || p_cactivi || ' gar='
            || p_cgarant;
      vobject        VARCHAR2(200) := 'PAC_PRODUCTOS.f_get_pregunprogaranvisible';
   BEGIN
      BEGIN
         pas := 100;

         SELECT Distinct cvisible
           INTO p_cvisible
           FROM pregunprogaran
          WHERE sproduc = p_sproduc
            AND cactivi = p_cactivi
            AND cgarant = p_cgarant
            AND cpregun = p_cpregun;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pas := 110;

            SELECT  Distinct cvisible
              INTO p_cvisible
              FROM pregunprogaran
             WHERE sproduc = p_sproduc
               AND cactivi = 0
               AND cgarant = p_cgarant
               AND cpregun = p_cpregun;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, pas, vparam, SQLERRM);
         RETURN 9001823;   -- No se ha podido recuperar la pregunta
   END f_get_pregunprogaranvisible;

    -- BUG 0022839 - FAL - 24/07/2012
   /***********************************************************************
      Recupera si hereda agente, forpag, recfra, clausulas, garantias del certif 0
      param in p_sproduc  : código de producto
      param in p_tipo_heren: indica cuál herencia a recuperar (agente:1, forpag:2, recfra:3, clausulas:4, garantias:5)
      param out p_chereda : indica si hereda o no del certificado 0
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_herencia_col(
      p_sproduc IN NUMBER,
      p_tipo_heren IN NUMBER,
      p_chereda OUT NUMBER)
      RETURN NUMBER IS
      pas            NUMBER := 1;
      vparam         VARCHAR2(500) := 'pro=' || p_sproduc || ' tipo_her=' || p_tipo_heren;
      vobject        VARCHAR2(200) := 'PAC_PRODUCTOS.f_get_herencia_col';
   BEGIN
      IF p_tipo_heren IS NULL THEN
         p_chereda := NULL;
         RETURN 9904026;
      END IF;

      --BUG 0023183: XVM :26/10/2012--INI. Añadimos tipo 14
      BEGIN
         SELECT DECODE(p_tipo_heren,
                       1, cagente,
                       2, cforpag,
                       3, recfra,
                       4, cclausu,
                       5, cgarant,
                       6, frenova,
                       7, cduraci,
                       8, ccorret,
                       9, ccompani,
                       10, cretorno,
                       11, crevali,
                       12, pirevali,
                       13, ctipcom,
                       14, ccoa,
                       -- Ini Bug 22839 - MDS - 30/10/2012
                       15, ctipcob,
                       16, cbancar,
                       17, ccobban,   -- Fin Bug 22839 - MDS - 30/10/2012
                       18, cdocreq,   -- Bug 27923/151007 - 27/08/2013 - AMC
                       19, casegurado,   -- Bug 30365/175325 - 03/06/2014 - AMC
                       20, cbeneficiario,   -- Bug 30365/175325 - 03/06/2014 - AMC
                       21, cversconv,   -- Bug 34461 - AFM 02/2015
					   22, cagenda -- AP
                                    )
           INTO p_chereda
           FROM prodherencia_colect
          WHERE sproduc = p_sproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- DRA:27/04/2015: Cansado de ver errores en la TAB_ERROR de productos que no heredan, pero que llaman a esta función
            p_chereda := 0;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, pas, vparam, SQLERRM);
         RETURN 9904026;   -- Error al leer de la tabla prodherencia_colect
   END f_get_herencia_col;

-- FI BUG 0022839

   -- BUG 0022839 - RSC - 13/08/2012
   FUNCTION f_get_frenova_col(pnpoliza IN NUMBER, pfrenova OUT DATE)
      RETURN NUMBER IS
      pas            NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnpoliza=' || pnpoliza;
      vobject        VARCHAR2(200) := 'PAC_PRODUCTOS.f_get_frenova_col';
      v_fvenova      seguros.frenova%TYPE;
      v_fvenova2     seguros.frenova%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      vnumerr        NUMBER;
      v_fcaranu      seguros.fcaranu%TYPE;
   BEGIN
      SELECT frenova, sseguro, sproduc, fcaranu
        INTO v_fvenova, v_sseguro, v_sproduc, v_fcaranu
        FROM seguros
       WHERE npoliza = pnpoliza
         AND ncertif = 0;

      vnumerr := f_ultrenova(v_sseguro, NVL(v_fcaranu, f_sysdate), v_fvenova2, v_nmovimi);
      pfrenova := NVL(v_fvenova,
                      ADD_MONTHS(v_fvenova2,
                                 NVL(pac_parametros.f_parproducto_n(v_sproduc,
                                                                    'PERIODO_POR_DEFECTO'),
                                     12)));

      -- BUG 26820 - 28/04/2013 - FAL
      IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'FRENOVA-1'), 0) = 1
         AND NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PERIODO_POR_DEFECTO'), 0) <> 0 THEN
         pfrenova := pfrenova - 1;
      END IF;

      -- FI BUG 26820
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, pas, vparam, SQLERRM);
         RETURN 101919;   -- Error al leer de la tabla prodherencia_colect
   END f_get_frenova_col;
-- FI BUG 0022839
END pac_productos;