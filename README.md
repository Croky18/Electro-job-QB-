# ⚡ Electro Job (QB)

Deze job laat spelers elektrische apparatuur afleveren als onderdeel van een leveringsdienst. Spelers starten de job bij een NPC, krijgen automatisch een voertuig toegewezen, en kunnen vervolgens pakketten afleveren op verschillende locaties. Elke levering levert een variabele beloning op.

---

## ⚠️ Belangrijke Informatie

- **Eenvoudig te configureren via `config.lua`**
  - Beloningen per levering  
  - Locaties van afleveringen  
  - NPC en voertuig instellingen  
  - Ondersteunt voor **QB**

- ✅ Automatisch voertuig bij start job  
- 🎬 Interactieve leverings-animatie  
- 💸 Variabele betaling per levering  
- 🔗 Volledig QB-compatible  
- 🧩 Fallback naar `ox_lib` voor menu

---

## 🔧 Installatie

1. Download de bestanden en plaats de map in je `resources` folder.  
2. Download en installeer de vereiste resources: 
   - [ox_lib (verplicht)](https://github.com/overextended/ox_lib)   
3. Voeg het script toe aan je `server.cfg`:
   ```cfg
   ensure electro-job
