# BUILD ANDROID — Grimstone (v0.5.5)

O sandbox (Linux ARM64 musl) NÃO consegue buildar o APK: falta JDK/SDK glibc e o
`aapt2` do Google é x86_64-only (tentativa com qemu+musl falhou em símbolos
fortify `__longjmp_chk`/`__memcpy_chk`). **O build final é no Mac do usuário.**

## Setup no Mac (uma vez, ~30min)

1. **Android Studio** → SDK Manager: instalar
   - Android SDK Platform 34
   - Android SDK Build-Tools 34
   - Platform-Tools
   - Command-line Tools
2. **Godot 4.7.2** → Editor Settings → Export → Android:
   - Android SDK Path: `~/Library/Android/sdk`
   - "Install Build Template" no projeto (Project → Install Android Build Template)
3. **Keystore de debug** (o Godot cria automaticamente) — para Play Store depois
   criar keystore de release própria:
   ```
   keytool -genkeypair -v -keystore grimstone-release.keystore -alias grimstone \
     -keyalg RSA -keysize 2048 -validity 10000
   ```

## Build

1. Project → Export… → preset "Android" (já commitado em `export_presets.cfg`)
2. Export Project (ou Export com debug pra testar)
3. Instalar no celular: `adb install export/grimstone.apk`

## O que já está configurado no preset

- arm64-v8a only (Play Store moderna; adicionar armeabi-v7a se quiser devices antigos)
- target SDK 34, immersive mode (fullscreen), internet permission (multiplayer)
- package `com.spacespanker.grimstone`, versão 0.5.5 (code 1)
- Gradle build ligado (obrigatório pra AAB da Play Store depois: mudar
  `gradle_build/export_format=1` pra gerar .aab)

## PENDÊNCIAS antes do primeiro APK (fila)

1. **Touch controls** — o jogo hoje é 100% teclado/mouse (WASD/setas, Q/E/R/G,
   B/C/K/F, Enter pro chat). Precisa: joystick virtual de movimento + botões de
   skill na tela + tap pra atacar (estilo Rucoy). PRÓXIMO CICLO.
2. **Orientação** — jogo é landscape 1280x720; conferir `screen/orientation`
   no project.godot (adicionar `sensor_landscape` se necessário).
3. Testar APK num device real antes de qualquer loja.
