--------------------------------------------------------
--  DDL for Package Body PAC_ECO_MONEDAS
--------------------------------------------------------
  CREATE OR REPLACE PACKAGE BODY PAC_ECO_MONEDAS IS
/****************************************************************************
   NOMBRE:      pac_eco_monedas
   PROPÓSITO:   Funciones y procedimientos para el tratamieto de monedas.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        05/05/2009   LPS               1. Creación del package.(Copia de Liberty)
   2.0        24/07/2014   dlF               2. 32364 - AGM800-Reaseguro - Problemas en la consulta de cesiones
   3.0        26/05/2020   ECP               3. IAXIS-13888. Gestión Agenda
****************************************************************************/

   /*************************************************************************
      FUNCTION f_obtener_moneda_defecto
      Obtiene la moneda por defecto para la instación actual.
      return             : eco_codmonedas.cmoneda%TYPE
   *************************************************************************/
   FUNCTION f_obtener_moneda_defecto
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
   /* 06/2008 Mantis 6091 Se modifica la obtención de la moneda, está en la tabla ECO_CODMONEDAS */
   BEGIN
      --v_moneda := f_parinstalacion_t('MONEDAINST');
      BEGIN
         SELECT cmoneda
           INTO v_moneda
           FROM eco_codmonedas
          WHERE bdefecto = 1;
      EXCEPTION
         WHEN OTHERS THEN
         -- 13888 -- 26/05/2020
            v_moneda := 'COP';
         -- 13888 -- 26/05/2020
      END;

/* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
      if v_moneda is null then
         -- DRA 05-02-2008: Desarrollo de las Monedas
         -- pac_errores.Lanzar_error(-20000, 102338, 'La aplicación no tienen ninguna moneda por defecto.');
         pac_mgr_session.p_raise_error ('obtener_moneda_defecto', NULL, 650224, NULL);
      end if;
      */
      IF v_moneda IS NULL THEN
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_defecto', NULL,
                     'La aplicación no tienen ninguna moneda por defecto.', SQLERRM);
      END IF;

      RETURN v_moneda;
   END f_obtener_moneda_defecto;

/*************************************************************************
   FUNCTION f_descripcion_moneda
   Obtiene el texto asociado a una moneda para un idioma concreto.
   param in p_moneda  : código de moneda
   param in p_idioma  : código de idioma
   return             : eco_codmonedas.cmoneda%TYPE
*************************************************************************/
   FUNCTION f_descripcion_moneda(
      p_moneda IN eco_desmonedas.cmoneda%TYPE,
      p_idioma IN eco_desmonedas.cidioma%TYPE,
      p_error OUT NUMBER)
      RETURN eco_desmonedas.tmoneda%TYPE IS
      v_descripcion  eco_desmonedas.tmoneda%TYPE;
   BEGIN
      SELECT tmoneda
        INTO v_descripcion
        FROM eco_desmonedas
       WHERE cmoneda = p_moneda
         AND cidioma = p_idioma;

      RETURN v_descripcion;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END f_descripcion_moneda;

/*************************************************************************
   FUNCTION f_lista_monedas
   Obtiene el texto asociado a una moneda para un idioma concreto.
   param in p_idioma  : código de idioma
   return             : Devuelve una referencia a un cursor ( ya abierto ) con las monedas y sus descripciones ordenadas.       --
                   --> ¡¡¡¡ Al final se debe cerrar el cursor !!!!. <--
   Estructura que devuelve el cursor:
          * codigo       (eco_desmonedas.cmoneda%TYPE)
          * descripcion  (eco_desmonedas.tmoneda%TYPE)
*************************************************************************/
   FUNCTION f_lista_monedas(p_idioma IN eco_desmonedas.cidioma%TYPE)
      RETURN NUMBER IS
      v_num_curs     NUMBER;
   BEGIN
      v_num_curs := DBMS_SQL.open_cursor;
      DBMS_SQL.parse
         (v_num_curs,
          'SELECT des.cmoneda as codigo, des.tmoneda as descripcion
                        FROM eco_codmonedas cod, eco_desmonedas des
                        WHERE des.cmoneda = cod.cmoneda AND des.cidioma = '
          || p_idioma
          || ' and cod.bvisualiza = 1 and cod.fbaja is null
                        ORDER BY cod.norden ASC, cod.cmoneda asc',
          DBMS_SQL.native);
      RETURN v_num_curs;
   END f_lista_monedas;

/*************************************************************************
   FUNCTION f_consulta_monedas
   Obtiene el texto asociado a una moneda para un idioma concreto.
   param in p_idioma  : código de idioma
   return             :  Devuelve una referencia a un cursor ( ya abierto ) con las monedas y sus datos. Primero se presentan    --
   las visualizables por orden y luego las no visualizables.
                   --> ¡¡¡¡ Al final se debe cerrar el cursor !!!!. <--
   Estructura que devuelve el cursor:
          * codigo       (eco_codmonedas.cmoneda%TYPE)
          * descripcion  (eco_desmonedas.tmoneda%TYPE)
          * tipo         (eco_codmonedas.ctipmoneda%TYPE)
          * decimales    (eco_codmonedas.ndecima%TYPE)
          * iso4217x     (eco_codmonedas.ciso4217x%TYPE)
          * iso4217n     (eco_codmonedas.ciso4217n%TYPE)
          * genero       (eco_codmonedas.cgenero%TYPE)
          * orden        (eco_codmonedas.norden%TYPE)
          * visualizable (eco_codmonedas.bvisualiza%TYPE)
*************************************************************************/
   FUNCTION f_consulta_monedas(p_idioma IN eco_desmonedas.cidioma%TYPE)
      RETURN NUMBER IS
      v_num_curs     NUMBER;
   BEGIN
      v_num_curs := DBMS_SQL.open_cursor;
      -- DRA 18-11-2007: Bug Mantis 3901
      DBMS_SQL.parse
         (v_num_curs,
          'SELECT des.cmoneda as codigo, des.tmoneda as descripcion, cod.ctipmoneda as tipo, cod.ndecima as decimales,
                                        cod.ciso4217x as iso4217x, cod.ciso4217n as iso4217n, cod.cgenero as genero, cod.norden as orden,
                                        cod.bvisualiza as visualizable, cod.bdefecto as bdefecto
                                 FROM eco_codmonedas cod, eco_desmonedas des
                                 WHERE des.cmoneda = cod.cmoneda AND des.cidioma = '
          || p_idioma
          || ' and cod.fbaja is null
                                 ORDER BY cod.bvisualiza desc, cod.norden ASC',
          DBMS_SQL.native);
      RETURN v_num_curs;
   END f_consulta_monedas;

/*************************************************************************
   FUNCTION f_consulta_monedas
   Obtiene el texto asociado a una moneda para un idioma concreto.
   param in p_idioma  : código de idioma
   param in p_criterios : record type de monedas
   return             : Devuelve una referencia a un cursor ( ya abierto ) con las monedas y sus datos. Primero se presentan    --
   las visualizables por orden y luego las no visualizables. Se le pueden pasar criterios para la
   selección y se hace con el mismo record, rellenando aquellos que deben intervenir en la selección.
                     --> ¡¡¡¡ Al final se debe cerrar el cursor !!!!. <--
   Estructura que devuelve el cursor:
          * codigo       (eco_codmonedas.cmoneda%TYPE)
          * descripcion  (eco_desmonedas.tmoneda%TYPE)
          * tipo         (eco_codmonedas.ctipmoneda%TYPE)
          * decimales    (eco_codmonedas.ndecima%TYPE)
          * iso4217x     (eco_codmonedas.ciso4217x%TYPE)
          * iso4217n     (eco_codmonedas.ciso4217n%TYPE)
          * genero       (eco_codmonedas.cgenero%TYPE)
          * orden        (eco_codmonedas.norden%TYPE)
          * visualizable (eco_codmonedas.bvisualiza%TYPE)
*************************************************************************/
   FUNCTION f_consulta_monedas(
      p_idioma IN eco_desmonedas.cidioma%TYPE,
      p_criterios IN t_moneda)
      RETURN NUMBER IS
      v_criterios    VARCHAR2(4000);
      v_num_curs     NUMBER;

      FUNCTION afegeix_and(p_cadena IN VARCHAR2)
         RETURN VARCHAR2 IS
      BEGIN
         IF TRIM(p_cadena) IS NOT NULL THEN
            RETURN p_cadena || ' and';
         ELSE
            RETURN p_cadena;
         END IF;
      END afegeix_and;
   BEGIN
      v_criterios := 'cod.cmoneda = des.cmoneda and cod.fbaja is null and des.cidioma = '
                     || p_idioma;

      IF p_criterios.codigo IS NOT NULL THEN
         v_criterios := afegeix_and(v_criterios) || ' cod.cmoneda = ''' || p_criterios.codigo
                        || CHR(39);
      END IF;

      IF p_criterios.descripciones.COUNT > 0 THEN
         IF p_criterios.descripciones(p_criterios.descripciones.FIRST).texto IS NOT NULL THEN
            v_criterios := afegeix_and(v_criterios) || ' upper(des.tmoneda) like upper('''
                           || p_criterios.descripciones(p_criterios.descripciones.FIRST).texto
                           || ''')';
         END IF;
      END IF;

      IF p_criterios.tipo IS NOT NULL THEN
         v_criterios := afegeix_and(v_criterios) || ' cod.ctipmoneda = ' || p_criterios.tipo;
      END IF;

      IF p_criterios.decimales IS NOT NULL THEN
         v_criterios := afegeix_and(v_criterios) || ' cod.ndecima = ' || p_criterios.decimales;
      END IF;

      IF p_criterios.iso4217x IS NOT NULL THEN
         v_criterios := afegeix_and(v_criterios) || ' cod.ciso4217x = '''
                        || p_criterios.iso4217x || CHR(39);
      END IF;

      IF p_criterios.iso4217n IS NOT NULL THEN
         v_criterios := afegeix_and(v_criterios) || ' cod.ciso4217n = '
                        || p_criterios.iso4217n;
      END IF;

      IF p_criterios.genero IS NOT NULL THEN
         v_criterios := afegeix_and(v_criterios) || ' cod.cgenero = ''' || p_criterios.genero
                        || CHR(39);
      END IF;

      IF p_criterios.orden IS NOT NULL THEN
         v_criterios := afegeix_and(v_criterios) || ' cod.norden = ' || p_criterios.orden;
      END IF;

      IF p_criterios.visualizable IS NOT NULL THEN
         v_criterios := afegeix_and(v_criterios) || ' cod.bvisualiza = '
                        || p_criterios.visualizable;
      END IF;

      v_num_curs := DBMS_SQL.open_cursor;
      -- DRA 18-11-2007: Bug Mantis 3901
      DBMS_SQL.parse
         (v_num_curs,
          'SELECT des.cmoneda as codigo, des.tmoneda as descripcion, decode(cod.ctipmoneda, ''2'', ''Unidad monetaria'',''Moneda'')  as tipo, cod.ndecima as decimales,
                                        cod.ciso4217x as iso4217x, cod.ciso4217n as iso4217n, cod.cgenero as genero, cod.norden as orden,
                                        cod.bvisualiza as visualizable, cod.bdefecto as bdefecto
                                 FROM eco_codmonedas cod, eco_desmonedas des
                                 WHERE '
          || v_criterios
          || '
                                 ORDER BY cod.bvisualiza desc, cod.norden ASC',
          DBMS_SQL.native);
      RETURN v_num_curs;
   END f_consulta_monedas;

/*************************************************************************
   FUNCTION f_consulta_moneda
   Devuelve el registro con los datos para la moneda indicada.
   p_moneda IN        : código de moneda
*************************************************************************/
   FUNCTION f_consulta_moneda(p_moneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN eco_codmonedas%ROWTYPE IS
      v_retorno      eco_codmonedas%ROWTYPE;
   BEGIN
      -- DRA 5-11-2007: Bug Mantis 3356
      -- DRA 18-11-2007: Bug Mantis 3901
      SELECT *
        INTO v_retorno
        FROM eco_codmonedas
       WHERE cmoneda = p_moneda;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END f_consulta_moneda;

/*************************************************************************
   FUNCTION f_datos_moneda_actualizar
   Devuelve los datos asociados a una moneda.
   p_moneda IN        : código de moneda
*************************************************************************/
   FUNCTION f_datos_moneda_actualizar(p_moneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN t_moneda IS
      v_moneda       t_moneda;
      v_indice       NUMBER := 1;

      CURSOR c_idiomas IS
         SELECT   cidioma
             FROM idiomas
         ORDER BY cidioma;
   BEGIN
      -- DRA 5-11-2007: Bug Mantis 3356
      -- DRA 18-11-2007: Bug Mantis 3901
      SELECT     cmoneda, ctipmoneda, ndecima, ciso4217x,
                 ciso4217n, cgenero, norden, bvisualiza,
                 cusualt, bdefecto
            INTO v_moneda.codigo, v_moneda.tipo, v_moneda.decimales, v_moneda.iso4217x,
                 v_moneda.iso4217n, v_moneda.genero, v_moneda.orden, v_moneda.visualizable,
                 v_moneda.usuario, v_moneda.bdefecto
            FROM eco_codmonedas
           WHERE cmoneda = p_moneda
      FOR UPDATE;

      -- Lo hago de esta manera para poder bloquear los registros para su actualización.
      FOR v_idiomas IN c_idiomas LOOP
         SELECT     tmoneda
               INTO v_moneda.descripciones(v_indice).texto
               FROM eco_desmonedas
              WHERE cmoneda = p_moneda
                AND cidioma = v_idiomas.cidioma
         FOR UPDATE;

         v_moneda.descripciones(v_indice).idioma := v_idiomas.cidioma;
         v_indice := v_indice + 1;
      END LOOP;

      RETURN v_moneda;
   END f_datos_moneda_actualizar;

/*************************************************************************
   PROCEDURE p_nueva_descripcion_moneda
   Permite crear una nueva descripcion para una moneda dada.
   p_moneda IN        : código de moneda
   p_descripcion IN   : Record type t_descripcion
   p_error OUT        : código de error
*************************************************************************/
   PROCEDURE p_nueva_descripcion_moneda(
      p_moneda IN eco_desmonedas.cmoneda%TYPE,
      p_descripcion IN t_descripcion,
      p_error OUT NUMBER) IS
   BEGIN
      INSERT INTO eco_desmonedas
                  (cmoneda, cidioma, tmoneda)
           VALUES (p_moneda, p_descripcion.idioma, p_descripcion.texto);

      p_error := 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_errores.Lanzar_error(-20003, 111391, 'Ya existe un registro en eco_desmonedas con valores : cmoneda = '||p_moneda||', cidioma : '||p_descripcion.idioma||', tmoneda : '||p_descripcion.texto);
         -- Literal OK. (Literales)
         */
         p_error := 111391;
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.nueva_descripcion_moneda', NULL,
                     'Ya existe un registro en eco_desmonedas, parametros: p_moneda = '
                     || p_moneda,
                     SQLERRM);
      WHEN OTHERS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_errores.Lanzar_error(-20004, 103869, 'Se ha producido el error '||sqlcode||' al insertar un registro en eco_desmonedas con valores : cmoneda = '||p_moneda||', cidioma : '||p_descripcion.idioma||', tmoneda : '||p_descripcion.texto);
         -- Literal OK. (Literales)*/
         p_error := 103869;
         p_tab_error
                    (f_sysdate, f_user, 'Pac_eco_monedas.nueva_descripcion_moneda', NULL,
                     'Se ha producido el error ' || SQLCODE
                     || ' al insertar un registro en eco_desmonedas con valores : cmoneda = '
                     || p_moneda || ', cidioma : ' || p_descripcion.idioma || ', tmoneda : '
                     || p_descripcion.texto,
                     SQLERRM);
   END p_nueva_descripcion_moneda;

/*************************************************************************
   PROCEDURE actualiza_descripcion
   Permite actualizar una descripcion para una monedad dada y un idioma concreto.
   p_moneda IN        : código de moneda
   p_descripcion IN   : Record type t_descripcion
*************************************************************************/
   PROCEDURE p_actualiza_descripcion(
      p_moneda IN eco_desmonedas.cmoneda%TYPE,
      p_descripcion IN t_descripcion) IS
   BEGIN
      UPDATE eco_desmonedas
         SET tmoneda = p_descripcion.texto
       WHERE cmoneda = p_moneda
         AND cidioma = p_descripcion.idioma;
   END p_actualiza_descripcion;

/*************************************************************************
   PROCEDURE p_borra_descripcion
   Permite borrar una descripcion para una monedad dada y un idioma concreto.
   p_moneda IN        : código de moneda
   p_descripcion IN   : Record type t_descripcion
*************************************************************************/
   PROCEDURE p_borra_descripcion(
      p_moneda IN eco_desmonedas.cmoneda%TYPE,
      p_descripcion IN t_descripcion) IS
   BEGIN
      DELETE      eco_desmonedas
            WHERE cmoneda = p_moneda
              AND cidioma = p_descripcion.idioma;
   END p_borra_descripcion;

/*************************************************************************
   PROCEDURE borra_descripciones
   Permite borrar una descripcion para una monedad dada y un idioma concreto.
   p_moneda IN        : código de moneda
*************************************************************************/
   PROCEDURE p_borra_descripciones(p_moneda IN eco_desmonedas.cmoneda%TYPE) IS
   BEGIN
      DELETE      eco_desmonedas
            WHERE cmoneda = p_moneda;
   END p_borra_descripciones;

/*************************************************************************
   PROCEDURE p_nueva_moneda
    Permite crear una nueva moneda.
    p_moneda IN        : código de moneda
    p_error OUT        : código de error
*************************************************************************/
   PROCEDURE p_nueva_moneda(p_moneda IN t_moneda, p_error OUT NUMBER) IS
      v_indice       BINARY_INTEGER;
      v_error        NUMBER;
   BEGIN
      -- DRA 5-11-2007: Bug Mantis 3356
      -- DRA 18-11-2007: Bug Mantis 3901
      INSERT INTO eco_codmonedas
                  (cmoneda, ctipmoneda, ndecima, ciso4217x,
                   ciso4217n, cgenero, norden, bvisualiza,
                   cusualt, falta, bdefecto)
           VALUES (p_moneda.codigo, p_moneda.tipo, p_moneda.decimales, p_moneda.iso4217x,
                   p_moneda.iso4217n, p_moneda.genero, p_moneda.orden, p_moneda.visualizable,
                   NVL(p_moneda.usuario, f_user), f_sysdate, p_moneda.bdefecto);

      IF p_moneda.descripciones.COUNT > 0 THEN
         v_indice := p_moneda.descripciones.FIRST;

         WHILE v_indice IS NOT NULL LOOP
            p_nueva_descripcion_moneda(p_moneda.codigo, p_moneda.descripciones(v_indice),
                                       v_error);
            v_indice := p_moneda.descripciones.NEXT(v_indice);
         END LOOP;
      END IF;

      p_error := 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_errores.Lanzar_error(-20005, 111391, 'Ya existe un registro en eco_codmonedas con valores : cmoneda = '||p_moneda.codigo);
         -- Literal OK. (Literales)
         */
         p_error := 111391;
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.p_nueva_moneda', NULL,
                     'Ya existe un registro en eco_codmonedas con valores : cmoneda = '
                     || p_moneda.codigo,
                     SQLERRM);
      WHEN OTHERS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_errores.Lanzar_error(-20006, 103869, 'Se ha producido el error '||sqlcode||' al insertar un registro en eco_codmonedas con valores : '||p_moneda.codigo||', '||p_moneda.tipo||', '||p_moneda.decimales||', '||p_moneda.iso4217x||', '||p_moneda.iso4217n||', '||p_moneda.genero||', '||p_moneda.orden||', '||p_moneda.visualizable||', '||p_moneda.usuario||', '||f_sysdate);
         -- Literal OK. (Literales)
         */
         p_error := 103869;
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.p_nueva_moneda', NULL,
                     'Se ha producido el error ' || SQLCODE
                     || ' al insertar un registro en eco_desmonedas con valores : : '
                     || p_moneda.codigo || ', ' || p_moneda.tipo || ', ' || p_moneda.decimales
                     || ', ' || p_moneda.iso4217x || ', ' || p_moneda.iso4217n || ', '
                     || p_moneda.genero || ', ' || p_moneda.orden || ', '
                     || p_moneda.visualizable || ', ' || p_moneda.usuario || ', ' || f_sysdate,
                     SQLERRM);
   END p_nueva_moneda;

/*************************************************************************
   PROCEDURE p_actualiza_moneda
    Permite actualizar una moneda.
    p_moneda IN        : código de moneda
*************************************************************************/
   PROCEDURE p_actualiza_moneda(p_moneda IN t_moneda) IS
      v_indice       BINARY_INTEGER;
      v_error        NUMBER;
   BEGIN
      UPDATE eco_codmonedas
         SET ctipmoneda = p_moneda.tipo,
             ndecima = p_moneda.decimales,
             ciso4217x = p_moneda.iso4217x,
             ciso4217n = p_moneda.iso4217n,
             cgenero = p_moneda.genero,
             norden = p_moneda.orden,
             bvisualiza = p_moneda.visualizable,
             cusumod = f_user,
             fmodifi = f_sysdate,
             bdefecto = p_moneda.bdefecto   -- DRA 18-11-2007: Bug Mantis 3901
       WHERE cmoneda = p_moneda.codigo;

      IF p_moneda.descripciones.COUNT > 0 THEN
         p_borra_descripciones(p_moneda.codigo);
         v_indice := p_moneda.descripciones.FIRST;

         WHILE v_indice IS NOT NULL LOOP
            p_nueva_descripcion_moneda(p_moneda.codigo, p_moneda.descripciones(v_indice),
                                       v_error);
            v_indice := p_moneda.descripciones.NEXT(v_indice);
         END LOOP;
      END IF;
   END p_actualiza_moneda;

/*************************************************************************
   PROCEDURE p_borra_moneda
    Permite actualizar una moneda.
    p_moneda IN        : código de moneda
*************************************************************************/
   PROCEDURE p_borra_moneda(p_moneda IN eco_codmonedas.cmoneda%TYPE) IS
   BEGIN
      UPDATE eco_codmonedas
         SET fbaja = f_sysdate,
             cusubaj = f_user   -- DRA 5-11-2007: Bug Mantis 3356
       WHERE cmoneda = p_moneda;
   END p_borra_moneda;

/*************************************************************************
   PROCEDURE p_desbloquear_registro
    Permite desbloquear el registro que se había bloqueado para la actualización
*************************************************************************/
   PROCEDURE p_desbloquear_registro IS
   BEGIN
      ROLLBACK;
   END p_desbloquear_registro;

/*************************************************************************
   FUNCTION f_ultima_modificacion
    Permite conocer el momento en que se realizó la última modificación. Si no se ha modificado nunca       --
    devolverá un nulo.
    p_codigo IN        : código de moneda
    return             : fecha de última modificación.
*************************************************************************/
   FUNCTION f_ultima_modificacion(p_codigo IN eco_codmonedas.cmoneda%TYPE)
      RETURN DATE IS
      v_fecha        DATE;
   BEGIN
      SELECT fmodifi
        INTO v_fecha
        FROM eco_codmonedas
       WHERE cmoneda = p_codigo;

      RETURN v_fecha;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END f_ultima_modificacion;

/*************************************************************************
   FUNCTION f_decimales
    Retorna el número de decimales de la moneda.
    p_moneda IN        : código de moneda
    return             : número de decimales de precisión de la moneda
*************************************************************************/
   FUNCTION f_decimales(p_moneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN NUMBER IS
      v_retorno      NUMBER;
   BEGIN
      SELECT ndecima
        INTO v_retorno
        FROM eco_codmonedas
       WHERE cmoneda = p_moneda;

      RETURN v_retorno;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END f_decimales;

/*************************************************************************
   FUNCTION f_existe_moneda_tpr
    Determina si la moneda está creada en TPR_MONEDAS
    psproduc IN        : código de producto
    pcmoneda IN        : código de moneda
    return             : '1' --> Existe la moneda, '0' --> no existe la moneda
*************************************************************************/
-- DRA 18-1-2008: Bug Mantis 4261. Retorna si la moneda está creada en TPR_MONEDAS
   FUNCTION f_existe_moneda_tpr(psproduc IN NUMBER, pcmoneda IN VARCHAR2)
      RETURN NUMBER IS
      CURSOR c_exi IS
         SELECT '1'
           FROM tpr_monedas c
          WHERE c.sproduc = psproduc
            AND c.cmonctr = pcmoneda;

      r_exi          c_exi%ROWTYPE;
      v_ret          NUMBER(1);
   BEGIN
      OPEN c_exi;

      FETCH c_exi
       INTO r_exi;

      IF c_exi%FOUND THEN
         v_ret := 1;
      ELSE
         v_ret := 0;
      END IF;

      CLOSE c_exi;

      RETURN(v_ret);
   -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF c_exi%ISOPEN THEN
            CLOSE c_exi;
         END IF;
   END f_existe_moneda_tpr;

/*************************************************************************
   FUNCTION f_obtener_moneda_producto
    Retorna la moneda por defecto para un producto en concreto
    psproduc IN        : código de producto
    return             : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_producto(psproduc IN productos.sproduc%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
   BEGIN
      SELECT cmonctr
        INTO v_moneda
        FROM tpr_monedas
       WHERE sproduc = psproduc
         AND bdefecto = 1;

      RETURN v_moneda;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_defecto;
         RETURN v_moneda;
      WHEN TOO_MANY_ROWS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error ('obtener_moneda_producto - too_many_rows', NULL, 650167, 'Producto: ' || psproduc || chr(10) || sqlerrm);
         -- Literal(Alta) --> Sólo puede existir una moneda por defecto
         */
         --p_error := 650167;
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.p_nueva_moneda', NULL,
                     'Sólo puede existir una moneda por defecto, Producto: ' || psproduc,
                     SQLERRM);
      WHEN OTHERS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error ('obtener_moneda_producto - others', NULL, 650167, 'Producto: ' || psproduc || chr(10) || sqlerrm);
         -- Literal(Alta) --> Sólo puede existir una moneda por defecto
         */
         --p_error := 650167;
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.p_nueva_moneda', NULL,
                     'Sólo puede existir una moneda por defecto, Producto: ' || psproduc,
                     SQLERRM);
   END f_obtener_moneda_producto;

    /*************************************************************************
      FUNCTION f_obtener_moneda_seguro2
       Retorna la moneda delproducto en el seguro
       psproduc IN        : código de producto
       return             : código de la moneda
   *************************************************************************/
   FUNCTION f_obtener_moneda_producto2(psproduc IN productos.sproduc%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
   BEGIN


      -- Bug 32364 - AGM800-Reaseguro - Problemas en la consulta de cesiones - 24-VII-2014 - dlF
      SELECT pac_eco_monedas.f_obtener_cmonint( pac_monedas.f_moneda_divisa(p.cdivisa))
             --pac_eco_monedas.f_obtener_cmonint(p.cdivisa)
      -- fin 32364 - AGM800-Reaseguro - Problemas en la consulta de cesiones - 24-VII-2014 - dlF
        INTO v_moneda
        FROM productos p
       WHERE p.sproduc = psproduc;

      RETURN v_moneda;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_defecto;
         RETURN v_moneda;
      WHEN TOO_MANY_ROWS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto2', NULL,
                     'Sólo puede existir una moneda por defecto, Póliza: ' || psproduc,
                     SQLERRM);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto2', NULL,
                     'Sólo puede existir una moneda por defecto, Producto: ' || psproduc,
                     SQLERRM);
   END f_obtener_moneda_producto2;

/*************************************************************************
   FUNCTION f_obtener_moneda_seguro
    Retorna la moneda grabada en el seguro
    psproduc IN        : código de producto
    ptablas IN         : tablas a actualizar. 'EST', 'SOL', etc...
    return             : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_seguro(
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2 DEFAULT '')
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT cmoneda
           INTO v_moneda
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         /* SELECT cmoneda
            INTO v_moneda
            FROM solseguros
           WHERE ssolicit = psseguro;*/
         NULL;
      ELSE
         SELECT m.cmonint
           INTO v_moneda
           FROM seguros s, monedas m
          WHERE sseguro = psseguro
            AND m.cmoneda = s.cmoneda
            AND m.cidioma = pac_md_common.f_get_cxtidioma;
      END IF;

      RETURN v_moneda;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_defecto;
         RETURN v_moneda;
      WHEN TOO_MANY_ROWS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error ('obtener_moneda_seguro - too_many_rows', NULL, 650167, 'Póliza: ' || psseguro || chr(10) || sqlerrm);
         -- Literal(Alta) --> Sólo puede existir una moneda por defecto
         */
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_seguro', NULL,
                     'Sólo puede existir una moneda por defecto, Póliza: ' || psseguro,
                     SQLERRM);
      WHEN OTHERS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error ('obtener_moneda_seguro - others', NULL, 650167, 'Póliza: ' || psseguro || chr(10) || sqlerrm);
         -- Literal(Alta) --> Sólo puede existir una moneda por defecto
         */
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_seguro', NULL,
                     'Sólo puede existir una moneda por defecto, Póliza: ' || psseguro,
                     SQLERRM);
   END f_obtener_moneda_seguro;

      /*************************************************************************
      FUNCTION f_obtener_moneda_seguro2
       Retorna la moneda delproducto en el seguro
       psproduc IN        : código de producto
       return             : código de la moneda
   *************************************************************************/
   FUNCTION f_obtener_moneda_seguro2(psseguro IN seguros.sseguro%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
   BEGIN

      -- Bug 32364 - AGM800-Reaseguro - Problemas en la consulta de cesiones - 24-VII-2014 - dlF
      /*
      BEGIN
         SELECT pac_eco_monedas.f_obtener_cmonint(p.cdivisa)
           INTO v_moneda
           FROM seguros s, productos p
          WHERE p.sproduc = s.sproduc
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT pac_eco_monedas.f_obtener_cmonint(p.cdivisa)
              INTO v_moneda
              FROM estseguros s, productos p
             WHERE p.sproduc = s.sproduc
               AND s.sseguro = psseguro;
      END;
      */
      BEGIN
         SELECT pac_eco_monedas.f_obtener_cmonint( pac_monedas.f_moneda_divisa(p.cdivisa))
           INTO v_moneda
           FROM seguros s, productos p
          WHERE p.sproduc = s.sproduc
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT pac_eco_monedas.f_obtener_cmonint( pac_monedas.f_moneda_divisa(p.cdivisa))
              INTO v_moneda
              FROM estseguros s, productos p
             WHERE p.sproduc = s.sproduc
               AND s.sseguro = psseguro;
      END;
      -- fin 32364 - AGM800-Reaseguro - Problemas en la consulta de cesiones - 24-VII-2014 - dlF


      RETURN v_moneda;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_defecto;
         RETURN v_moneda;
      WHEN TOO_MANY_ROWS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_seguro2', NULL,
                     'Sólo puede existir una moneda por defecto, Póliza: ' || psseguro,
                     SQLERRM);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_seguro2', NULL,
                     'Sólo puede existir una moneda por defecto, Póliza: ' || psseguro,
                     SQLERRM);
   END f_obtener_moneda_seguro2;

/*************************************************************************
   FUNCTION f_obtener_moneda_producto
    Retorna la moneda por defecto para un producto en concreto
    pcramo IN           : código del ramo
    pcmodali IN         : código de modalidad
    pctipseg IN         : código de tipo de seguo
    pccolect IN         : código de colectivo
    return              : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_producto(
      pcramo IN productos.cramo%TYPE,
      pcmodali IN productos.cmodali%TYPE,
      pctipseg IN productos.ctipseg%TYPE,
      pccolect IN productos.ccolect%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
   BEGIN
      SELECT cmonctr
        INTO v_moneda
        FROM tpr_monedas m, productos p
       WHERE p.cramo = pcramo
         AND p.cmodali = pcmodali
         AND p.ctipseg = pctipseg
         AND p.ccolect = pccolect
         AND m.sproduc = p.sproduc
         AND m.bdefecto = 1;

      RETURN v_moneda;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_defecto;
         RETURN v_moneda;
      WHEN TOO_MANY_ROWS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error (obtener_moneda_producto - too_many_rows, NULL, 650167, Producto:  || pcramo ||-|| pcmodali ||-|| pctipseg ||-|| pccolect || chr(10) || sqlerrm);
         -- Literal(Alta) --> Sólo puede existir una moneda por defecto
         */
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto', NULL,
                     'Sólo puede existir una moneda por defecto, Producto: ' || pcramo || '-'
                     || pcmodali || '-' || pctipseg || '-' || pccolect,
                     SQLERRM);
      WHEN OTHERS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error (obtener_moneda_producto - others, NULL, 650167, Producto:  || pcramo ||-|| pcmodali ||-|| pctipseg ||-|| pccolect || chr(10) || sqlerrm);
         */
         -- Literal(Alta) --> Sólo puede existir una moneda por defecto
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto', NULL,
                     'Sólo puede existir una moneda por defecto, Producto: ' || pcramo || '-'
                     || pcmodali || '-' || pctipseg || '-' || pccolect,
                     SQLERRM);
   END f_obtener_moneda_producto;

/*************************************************************************
   FUNCTION f_obtener_moneda_recibo
    Retorna la moneda de un recibo en concreto
    pnrecibo IN           : número de recibo
    ptablas IN            : tablas a actualizar. EST, SOL, etc...
    return                : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_recibo(
      pnrecibo IN recibos.nrecibo%TYPE,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
   BEGIN
      /*IF ptablas = CAR THEN
          SELECT r.cmonseg
              INTO v_moneda
              FROM RECIBOSCAR r
              WHERE r.nrecibo = pnrecibo;
      */
      /*ELSIF ptablas = PRE THEN -- LPS - BUG 9804 - 05/05/2009 - comentado ya que no existe en iAXIS
          SELECT r.cmonseg
              INTO v_moneda
              FROM ADM_RECIBOSPRE r
              WHERE r.nrecpre = pnrecibo;
      */
      /*ELSE
          SELECT r.cmonseg
              INTO v_moneda
              FROM RECIBOS r
              WHERE r.nrecibo = pnrecibo;
      END IF;*/
      RETURN v_moneda;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_defecto;
         RETURN v_moneda;
      WHEN TOO_MANY_ROWS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error (obtener_moneda_recibo - too_many_rows, NULL, 650167, recibo:  || pnrecibo || chr(10) || sqlerrm);
         -- Literal(Alta) --> Sólo puede existir una moneda por defecto
         */
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto', NULL,
                     'recibo: ' || pnrecibo, SQLERRM);
      WHEN OTHERS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error (obtener_moneda_recibo - others, NULL, 650167, recibo:  || pnrecibo || chr(10) || sqlerrm);
         -- Literal(Alta) --> Sólo puede existir una moneda por defecto
         */
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto', NULL,
                     'recibo: ' || pnrecibo, SQLERRM);
   END f_obtener_moneda_recibo;

/*************************************************************************
   FUNCTION f_obtener_moneda_recibo2
    Retorna la moneda de un recibo en concreto
    pnrecibo IN           : número de recibo
    return                : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_recibo2(pnrecibo IN recibos.nrecibo%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
   BEGIN
      SELECT f_obtener_moneda_seguro2(r.sseguro)
        INTO v_moneda
        FROM recibos r
       WHERE r.nrecibo = pnrecibo;

      RETURN v_moneda;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_defecto;
         RETURN v_moneda;
      WHEN TOO_MANY_ROWS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_recibo2', NULL,
                     'Sólo puede existir una moneda por defecto, recibo: ' || pnrecibo,
                     SQLERRM);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_recibo2', NULL,
                     'Sólo puede existir una moneda por defecto, recibo: ' || pnrecibo,
                     SQLERRM);
   END f_obtener_moneda_recibo2;

/*************************************************************************
   FUNCTION f_obtener_moneda_prod_seg
    Retorna la moneda de un recibo en concreto
    psseguro IN           : código de seguro
    ptablas IN            : tablas a actualizar. EST, SOL, etc...
    return                : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_prod_seg(
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      v_moneda       eco_codmonedas.cmoneda%TYPE;
      v_sproduc      productos.sproduc%TYPE;
   BEGIN
      /*IF ptablas = EST THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = SOL THEN
         SELECT sproduc
           INTO v_sproduc
           FROM solseguros
          WHERE ssolicit = psseguro;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;*/
      v_moneda := pac_eco_monedas.f_obtener_moneda_producto(v_sproduc);
      RETURN v_moneda;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_defecto;
         RETURN v_moneda;
      WHEN TOO_MANY_ROWS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error (obtener_moneda_prod_seg - too_many_rows, NULL, 650167, seguro:  || psseguro || chr(10) || sqlerrm);
         */
         -- 650167
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto', NULL,
                     'obtener_moneda_prod_seg - too_many_rows, seguro: ' || psseguro, SQLERRM);
      WHEN OTHERS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.p_raise_error (obtener_moneda_prod_seg - others, NULL, 650167, seguro:  || psseguro || chr(10) || sqlerrm);
         */
         -- 650167
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto', NULL,
                     'obtener_moneda_prod_seg - other, sseguro: ' || psseguro, SQLERRM);
   END f_obtener_moneda_prod_seg;

/*************************************************************************
   FUNCTION f_cambia_moneda_seguro
    Analiza / Realiza el cambio de la moneda o fecha de cambio en una póliza
    psseguro IN           : código de seguro
    pnriesgo IN           : número de riesgo
    pnmovimi IN           : número de movimiento
    pmonedaold IN         : código de moneda antigua
    pmonedanew IN         : código de moneda nueva
    pfcambio IN           : fecha del cambio
    pcmotmov IN           : Mótivo del movimiento
    paccion IN            : Acción --> P: Prueba  R: Real
    return                : código de la moneda
*************************************************************************/
   FUNCTION f_cambia_moneda_seguro(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN NUMBER,   -- DRA 2-7-08: bug mantis 6484
      pnmovimi IN NUMBER,   -- DRA 2-7-08: bug mantis 6484
      pmonedaold IN eco_codmonedas.cmoneda%TYPE,
      pmonedanew IN eco_codmonedas.cmoneda%TYPE,
      pfcambio IN DATE,
      pcmotmov IN VARCHAR2,
      paccion IN VARCHAR2 DEFAULT 'P')   --> P: Prueba  R: Real
      RETURN NUMBER IS
      v_nerror       NUMBER := 0;
      v_cont         NUMBER := 0;
      v_npoliza      estseguros.npoliza%TYPE;
      v_ncertif      estseguros.ncertif%TYPE;
      v_sseguro      estseguros.sseguro%TYPE;
      --v_cmonori      estseguros.cmonseg%TYPE;  -- LPS - BUG 9804 - 05/05/2009
      v_cramo        estseguros.cramo%TYPE;
      v_cmodali      estseguros.cmodali%TYPE;
      v_ctipseg      estseguros.ctipseg%TYPE;
      v_ccolect      estseguros.ccolect%TYPE;
      v_cactivi      estseguros.cactivi%TYPE;
      v_fefecto      estseguros.fefecto%TYPE;
      v_csubpro      productos.csubpro%TYPE;
      v_fechas_dist  NUMBER;
      v_fcambioori   DATE;
      v_numregs      NUMBER;
      v_error        NUMBER;
   BEGIN
      /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS

      pac_mgr_session.err := pac_mgr_session.f_push(F_CAMBIA_MONEDA_SEGURO);

      if pac_mgr_session.f_debug then
         pac_mgr_session.p_mensajedebug(- psseguro [||psseguro||]);
         pac_mgr_session.p_mensajedebug(- pnriesgo [||pnriesgo||]);
         pac_mgr_session.p_mensajedebug(- pnmovimi [||pnmovimi||]);
         pac_mgr_session.p_mensajedebug(- pmonedaold [||pmonedaold||]);
         pac_mgr_session.p_mensajedebug(- pmonedanew [||pmonedanew||]);
         pac_mgr_session.p_mensajedebug(- pcmotmov [||pcmotmov||]);
         pac_mgr_session.p_mensajedebug(- paccion [||paccion||]);
      end if;

      */

      -- DRA 2-7-08: bug mantis 6484
      -- Borramos tanto estgaranseg como estpregunseg si se modifica
      --  la fecha de efecto (=fcambio) o la moneda del seguro
      v_sseguro := NULL;

      IF paccion = 'P' THEN
         -- Contamos si tiene insertadas preguntas o garantías
         SELECT COUNT(contador)
           INTO v_cont
           FROM (SELECT '1' contador
                   FROM estpregunseg
                  WHERE sseguro = psseguro
                    AND(nriesgo = pnriesgo
                        OR pnriesgo IS NULL)
                    AND nmovimi = pnmovimi
                    AND NVL(pmonedaold, '**') <> NVL(pmonedanew, '**')
                 UNION ALL
                 SELECT '1' contador
                   FROM estgaranseg
                  WHERE sseguro = psseguro
                    AND(nriesgo = pnriesgo
                        OR pnriesgo IS NULL)
                    AND nmovimi = pnmovimi
                    AND pcmotmov = 100);

         IF v_cont > 0 THEN
            IF NVL(pmonedaold, '**') <> NVL(pmonedanew, '**') THEN
               v_nerror := 650346;
            ELSE
               v_nerror := 650431;
            END IF;
         END IF;
      ELSIF paccion = 'R' THEN
         DELETE FROM estpregunseg
               WHERE sseguro = psseguro
                 AND(nriesgo = pnriesgo
                     OR pnriesgo IS NULL)
                 AND nmovimi = pnmovimi
                 AND NVL(pmonedaold, '**') <> NVL(pmonedanew, '**');

         SELECT COUNT(1)
           INTO v_numregs
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND(nriesgo = pnriesgo
                OR pnriesgo IS NULL)
            AND nmovimi = pnmovimi
            AND pcmotmov = 100;

         DELETE FROM estgaranseg
               WHERE sseguro = psseguro
                 AND(nriesgo = pnriesgo
                     OR pnriesgo IS NULL)
                 AND nmovimi = pnmovimi
                 AND pcmotmov = 100;

         -- Analizamos si es un certificado 0 para recrear las estgaranseg
         SELECT e.npoliza, e.ncertif,   -- pac_eco_monedas.f_obtener_moneda_producto(e.sproduc),
                                     e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                e.fefecto, p.csubpro
           INTO v_npoliza, v_ncertif,   -- v_cmonori,
                                     v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                v_fefecto, v_csubpro
           FROM estseguros e, productos p
          WHERE e.sseguro = psseguro
            AND p.cramo = e.cramo
            AND p.cmodali = e.cmodali
            AND p.ctipseg = e.ctipseg
            AND p.ccolect = e.ccolect;

         -- Miramos si proviene de un grabación de una propuesta de alta
         BEGIN
            SELECT s.sseguro
              INTO v_sseguro
              FROM seguros s, estseguros e
             WHERE e.sseguro = psseguro
               AND s.sseguro = e.ssegpol;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_sseguro := NULL;
         END;

         -- Si es un certificado n, y se está modificando
         IF v_ncertif <> 0
            AND v_numregs > 0
            AND v_csubpro <> 6 THEN
            -- LPS - BUG 9804 - 05/05/2009 Comentado
            /*IF v_sseguro IS NULL THEN
               SELECT sseguro, fcambio
                 INTO v_sseguro, v_fcambioori
                 FROM seguros
                WHERE npoliza = v_npoliza
                  AND ncertif = 0;
            ELSE
               SELECT sseguro, fcambio
                 INTO v_sseguro, v_fcambioori
                 FROM seguros
                WHERE sseguro = v_sseguro;
            END IF;*/

            -- Si las monedas son diferentes habrá que recalcular los importes de las garantías
            IF v_fcambioori <> pfcambio THEN
               --OR v_cmonori <> pmonedanew THEN
               v_fechas_dist := 1;
            ELSE
               v_fechas_dist := 0;
            END IF;
         /*INSERT INTO estgaranseg
                     (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali, ctarifa,
                      icapital, precarg, iextrap, iprianu, ffinefe, cformul, ctipfra,
                      ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                      itarifa, itarrea, ipritot, icaptot,   -- LPS - BUG 9804 - 05/05/2009 - cgasgar, pgasadq, pgasadm,
                                                         pdtoint, idtoint, ftarifa,
                      crevalcar, ccampanya, nversio, cmatch, tdesmat, pintfin, cref,
                      cintref, pdif, pinttec, nparben, nbns, tmgaran, cfranq, nfraver,
                      ngrpgara, ngrpfra, nordfra, pdtofra,   -- LPS - BUG 9804 - 05/05/2009 - ipriext,
                                                          cderreg, feprev, fpprev, percre,
                      nmovima, cageven, nfactor, nlinea, cmotmov, finider, falta, ctarman,
                      cobliga, ctipgar,   --,
            --isubtot, pdtofs, idtofs, icapitalseg, iextrapseg,
            --iprianuseg, ifranquseg, irecargseg, ipritarseg,
            --idtocomseg, irevaliseg, itarifaseg, itarreaseg,
            --ipritotseg, icaptotseg, idtointseg, ipriextseg,
            --isubtotseg, idtofsseg,
                      fcambio) -- LPS - BUG 9804 - 05/05/2009 - la fecha de cambio si que hace falta dar de alta.
            SELECT cgarant, nriesgo, nmovimi, psseguro, v_fefecto, norden, crevali, ctarifa,
                   icapital, precarg, iextrap, iprianu, NULL, cformul, ctipfra, ifranqu,
                   irecarg, ipritar, pdtocom, idtocom, prevali, irevali, itarifa, itarrea,
                   ipritot, icaptot,   -- LPS - BUG 9804 - 05/05/2009 - cgasgar, pgasadq,  pgasadm,
                                    pdtoint, idtoint, NULL, crevalcar, ccampanya, nversio,
                   cmatch, tdesmat, pintfin, cref, cintref, pdif, pinttec, nparben, nbns,
                   tmgaran, cfranq, nfraver, ngrpgara, ngrpfra, nordfra, pdtofra,   -- LPS - BUG 9804 - 05/05/2009 - ipriext,
                                                                                 cderreg,
                   feprev, fpprev, percre, nmovima, cageven, nfactor, nlinea, cmotmov,
                   finider, NULL, ctarman, 1,
                   (SELECT ctipgar
                      FROM garanpro
                     WHERE cramo = v_cramo
                       AND cmodali = v_cmodali
                       AND ctipseg = v_ctipseg
                       AND ccolect = v_ccolect
                       AND cgarant = s.cgarant
                       AND cactivi = v_cactivi)   /* LPS - BUG 9804 - 05/05/2009 - (pac_axctr) DECODE (pac_axctr.garantias_por_activi_si_no
                                                                                      --(v_cramo,
                                                                                       --v_cmodali,
                                                                                      -- v_ctipseg,
                                                                                      -- v_ccolect,
                                                                                      -- v_cactivi
                                                                                     -- ), 0, 0,
                                                                                     v_cactivi)
                                                                                     */-- LPS - BUG 9804 - 05/05/2009 - (isubtot, pdtofs, idtofs), isubtot, pdtofs, idtofs,
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (icapitalseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 icapital),
                                                                                                        icapitalseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (iextrapseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 iextrap),
                                                                                                        iextrapseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (iprianuseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 iprianu),
                                                                                                        iprianuseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (ifranquseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 ifranqu),
                                                                                                        ifranquseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (irecargseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 irecarg),
                                                                                                        irecargseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (ipritarseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 ipritar),
                                                                                                        ipritarseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (idtocomseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 idtocom),
                                                                                                        idtocomseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (irevaliseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 irevali),
                                                                                                        irevaliseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (itarifaseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 itarifa),
                                                                                                        itarifaseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (itarreaseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 itarrea),
                                                                                                        itarreaseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (ipritotseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 ipritot),
                                                                                                        ipritotseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (icaptot, icaptotseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 icaptot),
                                                                                                        icaptotseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (idtoint, idtointseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 idtoint),
                                                                                                        idtointseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (ipriext, ipriextseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 ipriext),
                                                                                                        ipriextseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (isubtot, isubtotseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 isubtot),
                                                                                                        isubtotseg),
                                                                              */
                                                                              /* LPS - BUG 9804 - 05/05/2009 - (idtofs, idtofseg) decode (v_fechas_dist, 1, pac_eco_tipocambio.importe_cambio (v_cmonori,
                                                                                                                 pmonedanew,
                                                                                                                 pfcambio,
                                                                                                                 idtofs),
                                                                                                        idtofsseg),
                                                                              */
          /*    , pfcambio
            FROM   garanseg s
             WHERE sseguro = v_sseguro
               AND(nriesgo = pnriesgo
                   OR pnriesgo IS NULL)
               AND nmovimi = pnmovimi;*/
         END IF;
      END IF;

      --
      <<salida>>
      /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         if pac_mgr_session.f_debug then
            pac_mgr_session.p_mensajedebug(Parms OUT Error [||v_nerror||]);
            pac_mgr_session.err := pac_mgr_session.f_pop(exit ok);
         end if;
      */
      RETURN v_nerror;
   EXCEPTION
      WHEN OTHERS THEN
         /* LPS - BUG 9804 - 05/05/2009 - Comentado para sustituir por control errores AXIS
         pac_mgr_session.tsqlerr := SQLERRM;

         v_nerror := sqlcode;
         if pac_mgr_session.f_debug then
            pac_mgr_session.p_mensajedebug(Parms OUT Error [||v_nerror||]);
            pac_mgr_session.err := pac_mgr_session.f_pop(exit When Others);
         end if;
         pac_mgr_session.p_raise_error (f_cambia_moneda_seguro, NULL, 109388, sqlerrm);

         -- Literal OK.
         */
         p_tab_error(f_sysdate, f_user, 'Pac_eco_monedas.f_obtener_moneda_producto', NULL,
                     'when others, seguro: ' || psseguro, SQLERRM);
   END f_cambia_moneda_seguro;

   FUNCTION f_obtener_formatos_moneda
      RETURN sys_refcursor IS
      cur            sys_refcursor;
   BEGIN
      OPEN cur FOR
         SELECT   m2.cmoneda, m2.cmonint, m1.patron, m1.bdefecto
             FROM eco_codmonedas m1, monedas m2
            WHERE m1.cmoneda = m2.cmonint
              AND m1.patron IS NOT NULL
              AND m2.cidioma = pac_iax_common.f_get_cxtidioma
         ORDER BY 1;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_ECO_MONEDAS.f_obtener_formatos_moneda', NULL,
                     'when others', SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda;

   FUNCTION f_obtener_formatos_moneda1(pmoneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN VARCHAR2 IS
      varret         eco_codmonedas.patron%TYPE;
   BEGIN
      SELECT m1.patron
        INTO varret
        FROM eco_codmonedas m1, monedas m2
       WHERE m1.cmoneda = m2.cmonint
         AND m1.patron IS NOT NULL
         AND m2.cidioma = pac_iax_common.f_get_cxtidioma
         AND m1.cmoneda = pmoneda;

      RETURN varret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC _ECO_MONEDAS.f_obtener_formatos_moneda1', NULL,
                     'when others', SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda1;

   FUNCTION f_obtener_formatos_moneda2(pmoneda IN monedas.cmoneda%TYPE)
      RETURN VARCHAR2 IS
      varret         eco_codmonedas.patron%TYPE;
   BEGIN
      SELECT m1.patron
        INTO varret
        FROM eco_codmonedas m1, monedas m2
       WHERE m1.cmoneda = m2.cmonint
         AND m1.patron IS NOT NULL
         AND m2.cidioma = pac_iax_common.f_get_cxtidioma
         AND m2.cmoneda = pmoneda;

      RETURN varret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ECO_MONEDAS.f_obtener_formatos_moneda2', NULL,
                     'when others', SQLERRM);
         RETURN NULL;
   END f_obtener_formatos_moneda2;

   FUNCTION f_obtener_cmonint(pmoneda IN monedas.cmoneda%TYPE)
      RETURN monedas.cmonint%TYPE IS
      varret         monedas.cmonint%TYPE;
   BEGIN
      SELECT m2.cmonint
        INTO varret
        FROM monedas m2
       WHERE m2.cidioma = pac_iax_common.f_get_cxtidioma
         AND m2.cmoneda = pmoneda;

      RETURN varret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ECO_MONEDAS.f_obtener_cmonint', NULL,
                     'when others', SQLERRM);
         RETURN NULL;
   END f_obtener_cmonint;

   FUNCTION f_obtener_cmoneda(pmoneda IN monedas.cmonint%TYPE)
      RETURN monedas.cmoneda%TYPE IS
      varret         monedas.cmoneda%TYPE;
   BEGIN
      SELECT m2.cmoneda
        INTO varret
        FROM monedas m2
       WHERE m2.cidioma = pac_iax_common.f_get_cxtidioma
         AND m2.cmonint = pmoneda;

      RETURN varret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ECO_MONEDAS.f_obtener_cmoneda', NULL,
                     'when others', SQLERRM);
         RETURN NULL;
   END f_obtener_cmoneda;

   FUNCTION f_obtener_moneda_informe(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN monedas.cmonint%TYPE IS
      v_moneda       monedas.cmonint%TYPE;
   BEGIN
      IF psseguro IS NOT NULL THEN
         v_moneda := pac_eco_monedas.f_obtener_moneda_seguro2(psseguro);
      ELSE
         v_moneda := pac_eco_monedas.f_obtener_moneda_producto2(psproduc);
      END IF;

      --En ENSA los kwanzas son conocidos como AKZ
      SELECT DECODE(v_moneda, 'AOA', 'AKZ', v_moneda)
        INTO v_moneda
        FROM DUAL;

      RETURN v_moneda;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ECO_MONEDAS.f_obtener_moneda_informe', NULL,
                     'when others', SQLERRM);
         RETURN NULL;
   END f_obtener_moneda_informe;

   FUNCTION f_obtener_moneda_literal(
      p_idioma IN eco_desmonedas.cidioma%TYPE,
      psproduc IN NUMBER)
      RETURN monedas.tdescri%TYPE IS
      v_moneda       monedas.tdescri%TYPE;
   BEGIN
      SELECT m.tdescri
        INTO v_moneda
        FROM productos p, monedas m
       WHERE p.sproduc = psproduc
         AND p.cdivisa = m.cmoneda
         AND m.cidioma = p_idioma;

      RETURN v_moneda;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_ECO_MONEDAS.f_obtener_moneda_literal', NULL,
                     'when others', SQLERRM);
         RETURN NULL;
   END f_obtener_moneda_literal;
END pac_eco_monedas;

/