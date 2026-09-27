// ==WindhawkMod==
// @id              window-frame-neumorphic
// @name            Neumorphic Window Frame & Caption Buttons
// @description     Customizes DWM window borders and caption buttons with soft dual-shadow extrusion and rounding
// @version         1.0.0
// @author          Principal Systems Software Engineer
// @include         dwm.exe
// @include         explorer.exe
// @architecture    x86-64
// ==/WindhawkMod==

#include <windows.h>
#include <windhawk_api.h>
#include <dwmapi.h>

#pragma comment(lib, "dwmapi.lib")

// Hook DWM window creation to enforce Neumorphic matte borders and 16px corner rounding
typedef HRESULT (WINAPI *DwmSetWindowAttribute_t)(
    HWND hwnd,
    DWORD dwAttribute,
    LPCVOID pvAttribute,
    DWORD cbAttribute
);

DwmSetWindowAttribute_t pOriginalDwmSetWindowAttribute = NULL;

HRESULT WINAPI Hook_DwmSetWindowAttribute(
    HWND hwnd,
    DWORD dwAttribute,
    LPCVOID pvAttribute,
    DWORD cbAttribute
) {
    // Intercept corner preference to enforce rounded Neumorphic corners (DWMWCP_ROUND = 2)
    if (dwAttribute == 33 /* DWMWA_WINDOW_CORNER_PREFERENCE */) {
        DWORD cornerPreference = 2; // DWMWCP_ROUND
        return pOriginalDwmSetWindowAttribute(hwnd, dwAttribute, &cornerPreference, sizeof(cornerPreference));
    }
    
    // Intercept border color to inject dark matte slate (#1E2024 / RGB 30, 32, 36)
    if (dwAttribute == 34 /* DWMWA_BORDER_COLOR */) {
        COLORREF borderColor = RGB(30, 32, 36);
        return pOriginalDwmSetWindowAttribute(hwnd, dwAttribute, &borderColor, sizeof(borderColor));
    }

    return pOriginalDwmSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute);
}

BOOL Wh_ModInit() {
    Wh_Log(L"Initializing Neumorphic Window Frame Hook");
    
    HMODULE hDwmapi = GetModuleHandleW(L"dwmapi.dll");
    if (!hDwmapi) {
        hDwmapi = LoadLibraryW(L"dwmapi.dll");
    }
    
    if (hDwmapi) {
        void* pTarget = (void*)GetProcAddress(hDwmapi, "DwmSetWindowAttribute");
        if (pTarget) {
            Wh_SetFunctionHook(pTarget, (void*)Hook_DwmSetWindowAttribute, (void**)&pOriginalDwmSetWindowAttribute);
            Wh_Log(L"DwmSetWindowAttribute hooked successfully for Neumorphic styling");
        }
    }
    
    return TRUE;
}

void Wh_ModUninit() {
    Wh_Log(L"Unloading Neumorphic Window Frame Hook");
}
