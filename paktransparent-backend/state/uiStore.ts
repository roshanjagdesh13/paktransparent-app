import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { STORAGE_KEYS } from '@/constants';

interface UIState {
  theme: 'light' | 'dark';
  language: 'en' | 'ur';
  sidebarOpen: boolean;
  notifications: Notification[];
  
  // Actions
  toggleTheme: () => void;
  setTheme: (theme: 'light' | 'dark') => void;
  setLanguage: (language: 'en' | 'ur') => void;
  toggleSidebar: () => void;
  setSidebarOpen: (open: boolean) => void;
  addNotification: (notification: Omit<Notification, 'id'>) => void;
  removeNotification: (id: string) => void;
  clearNotifications: () => void;
}

interface Notification {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  duration?: number;
}

export const useUIStore = create<UIState>()(
  persist(
    (set) => ({
      theme: 'light',
      language: 'en',
      sidebarOpen: true,
      notifications: [],

      toggleTheme: () => {
        set((state) => {
          const newTheme = state.theme === 'light' ? 'dark' : 'light';
          
          // Update document class
          if (typeof document !== 'undefined') {
            document.documentElement.classList.toggle('dark', newTheme === 'dark');
          }
          
          return { theme: newTheme };
        });
      },

      setTheme: (theme: 'light' | 'dark') => {
        // Update document class
        if (typeof document !== 'undefined') {
          document.documentElement.classList.toggle('dark', theme === 'dark');
        }
        
        set({ theme });
      },

      setLanguage: (language: 'en' | 'ur') => {
        // Update document direction for Urdu
        if (typeof document !== 'undefined') {
          document.documentElement.dir = language === 'ur' ? 'rtl' : 'ltr';
          document.documentElement.lang = language;
        }
        
        set({ language });
      },

      toggleSidebar: () => {
        set((state) => ({ sidebarOpen: !state.sidebarOpen }));
      },

      setSidebarOpen: (open: boolean) => {
        set({ sidebarOpen: open });
      },

      addNotification: (notification: Omit<Notification, 'id'>) => {
        const id = `notification_${Date.now()}`;
        const newNotification: Notification = { ...notification, id };
        
        set((state) => ({
          notifications: [...state.notifications, newNotification],
        }));

        // Auto-remove notification after duration
        if (notification.duration !== 0) {
          setTimeout(() => {
            set((state) => ({
              notifications: state.notifications.filter((n) => n.id !== id),
            }));
          }, notification.duration || 5000);
        }
      },

      removeNotification: (id: string) => {
        set((state) => ({
          notifications: state.notifications.filter((n) => n.id !== id),
        }));
      },

      clearNotifications: () => {
        set({ notifications: [] });
      },
    }),
    {
      name: STORAGE_KEYS.THEME,
      partialize: (state) => ({
        theme: state.theme,
        language: state.language,
      }),
    }
  )
);
