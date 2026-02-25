# Plan de Migración de API

## 📋 Análisis de Cambios

Según la nueva documentación de la API, los endpoints han cambiado su estructura. Necesitamos actualizar todas las entidades y modelos.

---

## 🏠 Home Feature (`/api/music/explore`)

### Cambios Necesarios:

**Antes:**
```json
{
  "moods_genres": [...],
  "home": [...],
  "charts": {...}
}
```

**Ahora:**
```json
{
  "moods": [...],
  "genres": [...],
  "charts": {
    "top_songs": [
      {
        "videoId": "...",
        "title": "...",
        "artist": "...",
        "stream_url": "...",
        "thumbnail": "..."
      }
    ],
    "trending": [...]
  }
}
```

### Tareas:
1. ✅ Actualizar `HomeResponse` para separar `moods` y `genres`
2. ✅ Actualizar `ChartPlaylist` → Crear `ChartSong` con `stream_url` y `thumbnail`
3. ✅ Eliminar `homeSections` (ya no viene en el endpoint)
4. ✅ Actualizar modelos para parsear nueva estructura

---

## 🔍 Search Feature

### Estado Actual:
- ✅ Ya tiene `stream_url` y `thumbnail` en `Song`
- ✅ Ya tiene `stream_url` y `thumbnail` en `RecentSearch`

### Tareas:
1. ✅ Verificar que todos los modelos parseen correctamente `stream_url` y `thumbnail`
2. ✅ Asegurar que `NowPlayingData` use `thumbnail` de mejor calidad

---

## 📚 Library Feature

### Estado Actual:
- ❌ Solo tiene UI básica sin funcionalidad
- ❌ No tiene Clean Architecture implementada

### Nuevos Endpoints a Implementar:
1. `GET /api/library/songs` - Obtener canciones favoritas
2. `POST /api/library/songs` - Agregar canción a favoritos
3. `DELETE /api/library/songs/:songId` - Eliminar canción
4. `GET /api/library/playlists` - Obtener playlists favoritas
5. `POST /api/library/playlists` - Agregar playlist
6. `DELETE /api/library/playlists/:playlistId` - Eliminar playlist
7. `GET /api/library/genres` - Obtener géneros favoritos
8. `POST /api/library/genres` - Agregar género
9. `DELETE /api/library/genres/:genreId` - Eliminar género
10. `GET /api/library/summary` - Resumen de biblioteca

### Tareas:
1. Crear entidades para Library (FavoriteSong, FavoritePlaylist, FavoriteGenre)
2. Crear modelos para Library
3. Crear data sources para Library
4. Crear repositories para Library
5. Crear use cases para Library
6. Crear cubits para Library
7. Actualizar UI de LibraryScreen

---

## 🎵 Charts Feature (Nuevo)

### Nuevo Endpoint:
- `GET /api/music/explore` ahora retorna `charts.top_songs` y `charts.trending`

### Tareas:
1. Crear entidad `ChartSong` con `videoId`, `title`, `artist`, `stream_url`, `thumbnail`
2. Actualizar `HomeResponse` para incluir `charts` con estructura correcta
3. Crear widget para mostrar charts en HomeScreen

---

## 📝 Prioridades

### Alta Prioridad:
1. ✅ Actualizar Home feature para nueva estructura de `/api/music/explore`
2. ✅ Crear entidades y modelos para charts
3. ✅ Verificar que Search feature tenga `stream_url` y `thumbnail`

### Media Prioridad:
4. Implementar Library feature completa con Clean Architecture
5. Actualizar UI para usar `thumbnail` de mejor calidad

### Baja Prioridad:
6. Optimizaciones y mejoras de UI
