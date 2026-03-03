# Ethornel Tools → GARbro

## Contexto del Problema

- GARbro extrae y descomprime archivos DSC automáticamente
- No guarda las keys de encriptación necesarias para recomprimir
- Mi herramienta (`ethornell-tools`) necesita las keys originales para comprimir correctamente los archivos DSC

---

## **Solución:** Sistema de Keys Local

### Durante **EXTRACCIÓN:**

1. Usuario extrae .arc a la carpeta que elija
2. GARbro analiza y extrae keys **durante** la extracción (antes de descomprimir cada archivo DSC)
3. Guarda `bgi_keys.dat` en la **misma carpeta** donde extrajo los archivos

### Durante **CREACIÓN:**

1. Usuario selecciona archivos sin extensión → "Create Archive"
2. Diálogo de creación incluye checkbox: `☑ Compress files using DSC keys`
   - Si **desmarcado**: empaqueta todo sin comprimir (ignora keys completamente)
   - Si **marcado**: continúa con búsqueda de keys
3. GARbro busca `bgi_keys.dat` en la carpeta donde están los archivos seleccionados
4. Si encuentra `bgi_keys.dat`:
   - Excluye automáticamente ese archivo del empaquetado si el usuario lo seleccionó
   - Usa las keys de ese archivo
5. Si **NO** lo encuentra o está **corrupto**:
   - Warning: "bgi_keys.dat not found or corrupted. Cannot compress DSC files without encryption keys."
   - Opciones: `[Pack Uncompressed]` `[Cancel]`
   - Si usuario elige `[Pack Uncompressed]`: empaqueta sin comprimir
   - Si usuario elige `[Cancel]`: cancela la operación
6. Por cada archivo a comprimir:
   - Si tiene key → comprime
   - Si **NO** tiene key → Warning individual: "Key for `{filename}` hasn't been found. What to do?"
     - Opciones: `[Pack Uncompressed]` `[Skip]` `[Pack All Uncompressed]` `[Skip All]` `[Cancel]`

---

## **Decisiones de Diseño:**

### **1.** Formato de bgi_keys.dat

- Formato JSON simple para trabajar con mis herramientas y GARbro a la vez sin problemas.
- Formato a adaptar para `ethornell-tools` y GARbro:

  ```json
  {
    "01_prologue1": "0xC2837D03",
    "01_prologue2": "0xD739163A",
    ...
  }
  ```

### **2.** Código/UI

- Intentar mantener el código y la UI mostrada lo más cercana posible al actual de GARbro.

---

## **Gestión de Múltiples Extracciones** (Merge Keys)

### **Problema**

Si extraes múltiples archivos .arc a la misma carpeta, cada extracción generaría su propio `bgi_keys.dat`, sobrescribiendo el anterior.

### **Solución:** Merge Automático

**Durante EXTRACCIÓN cuando ya existe `bgi_keys.dat`:**

1. GARbro lee el `bgi_keys.dat` existente
2. Por cada key nueva del .arc que se está extrayendo:
   - **Si el archivo no existe en el JSON:** agregar directamente
   - **Si el archivo existe con la misma key:** ignorar (no hacer nada)
   - **Si el archivo existe con key diferente:**

     ```js
     Warning: The key for {filename} has changed.
     Old: 0x02207D06
     New: 0xABCDEF00
     
     [Overwrite] [Skip] [Overwrite All] [Skip All] [Cancel]
     ```

     - **[Overwrite]**: Actualiza solo esta key
     - **[Skip]**: Mantiene la key vieja, no actualiza esta
     - **[Overwrite All]**: Actualiza esta y todas las siguientes sin preguntar
     - **[Skip All]**: Mantiene todas las keys viejas sin actualizar ninguna
     - **[Cancel]**: Cancela toda la extracción
3. Guardar el JSON actualizado con el merge

**Ejemplo de merge:**

```json
// Después de extraer data01500.arc
{
    "01_prologue1": "0x02207D06",
    "menu_main": "0x12345678"
}

// Después de extraer data01600.arc en la misma carpeta
{
    "01_prologue1": "0x02207D06",
    "menu_main": "0x12345678",
    "02_scene1": "0xABCDEF00",      // ← Agregadas
    "battle_system": "0x11111111"   // ← Agregadas
}
```

**Nota:** Como no puede haber archivos DSC con el mismo nombre en diferentes .arc del mismo juego, los conflictos de keys solo deberían ocurrir en casos anormales (re-extraer el mismo .arc, extraer un .arc de otro juego en la misma carpeta, etc).

---

## **Lo que Necesito Implementar en GARbro**

1. **Módulo de análisis de keys** (portar lógica de `analyze_key.py`)
2. **Hook en el proceso de extracción** para capturar keys antes de descomprimir
3. **Escritura de `bgi_keys.dat`** en carpeta de extracción
4. **Lectura de keys** durante creación de .arc (usando archivo creado)
5. **Lógica de compresión DSC** (portar `dsc_compress.py`)
6. **Sistema de warnings** con todas las opciones definadas
7. **Checkbox "Compress files using DSC keys"** en diálogo de creación
8. **Exclusión automática** de `bgi_keys.dat` al crear .arc (si el usuario lo selecciona)

---

## **Casos de Uso Cubiertos**

### **Caso 1:** Workflow Normal

```fix
1. Extraigo data01500.arc a C:/proyecto/
2. Edito archivos en C:/proyecto/
3. Selecciono archivos → Create Archive → ☑ Compress
4. GARbro encuentra C:/proyecto/bgi_keys.dat ✅
5. Crea data01500_new.arc comprimido correctamente
```

### **Caso 2:** Usuario Mueve Archivos sin Keys

```fix
1. Extraigo data01500.arc a C:/temp/
2. Muevo archivos a C:/proyecto/ (sin bgi_keys.dat)
3. Selecciono archivos → Create Archive → ☑ Compress
4. Warning: bgi_keys.dat not found
5. Usuario elige [Pack Uncompressed] → empaqueta sin comprimir ✅
```

### **Caso 3:** Archivos Nuevos

```fix
1. Extraigo data01500.arc
2. Agrego "mi_escena_nueva" (creado por mí)
3. Selecciono todos → Create Archive → ☑ Compress
4. Warning para "mi_escena_nueva": no key found
5. Usuario elige [Pack Uncompressed] → archivo se empaqueta sin comprimir ✅
```

### **Caso 4:** Usuario No Quiere Comprimir

```fix
1. Selecciono archivos → Create Archive → ☐ Compress (desmarcado)
2. GARbro empaqueta todo sin comprimir, ignora keys completamente ✅
```
