import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { User, UserRole } from '@/types';
import { GovernmentRole } from '@/types/workflow';
import { GOVERNMENT_HIERARCHY } from '@/types/government';
import { STORAGE_KEYS } from '@/constants';
import {
  hashPassword,
  verifyPassword,
  createSession,
  validateSession,
  updateSessionActivity,
  createAuditLog,
  isAccountLocked,
  recordFailedLogin,
  resetLoginAttempts,
  generateCSRFToken,
  SessionData,
} from '@/services/securityService';

interface AuthState {
  user: User | null;
  token: string | null;
  session: SessionData | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  loginError: string | null;
  
  // Actions
  login: (email: string, password: string, role: UserRole) => Promise<void>;
  logout: () => void;
  register: (userData: Partial<User>, password: string) => Promise<void>;
  updateUser: (userData: Partial<User>) => void;
  setLoading: (loading: boolean) => void;
  setGovernmentRole: (role: GovernmentRole) => void;
  checkSessionValidity: () => boolean;
  refreshSession: () => void;
}

// Mock user database for demonstration
// In production, this would be handled by the backend
const mockUserDatabase: Map<string, { email: string; password: string; userData: User }> = new Map();

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      session: null,
      isAuthenticated: false,
      isLoading: false,
      loginError: null,

      login: async (email: string, password: string, role: UserRole) => {
        set({ isLoading: true, loginError: null });
        
        try {
          // Check account lockout
          const lockoutStatus = isAccountLocked(email);
          if (lockoutStatus.locked) {
            const minutesLeft = Math.ceil((lockoutStatus.lockedUntil! - Date.now()) / 60000);
            throw new Error(`Account locked. Try again in ${minutesLeft} minutes.`);
          }

          // Simulate API delay
          await new Promise(resolve => setTimeout(resolve, 1000));
          
          // Get stored user from mock database
          const storedUser = mockUserDatabase.get(email);
          
          // For demo, also accept any login with a default password "Demo@123"
          const isValidPassword = storedUser 
            ? await verifyPassword(password, storedUser.password)
            : password === 'Demo@123';
          
          if (!isValidPassword) {
            // Record failed attempt
            const lockoutResult = recordFailedLogin(email);
            if (lockoutResult.locked) {
              throw new Error(`Too many failed attempts. Account locked for 15 minutes.`);
            }
            throw new Error(`Invalid credentials. ${lockoutResult.attemptsRemaining} attempts remaining.`);
          }

          // Reset login attempts on successful login
          resetLoginAttempts(email);
          
          // Create user object
          const mockUser: User = storedUser ? storedUser.userData : {
            id: `user_${Date.now()}`,
            email,
            name: role === 'citizen' ? 'Ahmad Khan' : 'Government Official',
            role,
            governmentRole: undefined,
            employeeCode: undefined,
            designation: undefined,
            approvalAuthority: undefined,
            avatar: role === 'citizen' 
              ? 'https://ui-avatars.com/api/?name=Ahmad+Khan&background=004b00&color=fff'
              : 'https://ui-avatars.com/api/?name=Official&background=003d87&color=fff',
            phone: '+92-300-1234567',
            province: 'punjab',
            district: 'Lahore',
            department: role === 'government' ? 'Ministry of Finance' : undefined,
            isVerified: true,
            createdAt: new Date(),
            lastLogin: new Date(),
          };

          // Create secure session
          const session = createSession(mockUser.id);
          
          // Generate CSRF token
          generateCSRFToken();
          
          // Create audit log
          createAuditLog(mockUser.id, 'LOGIN', 'auth', true, { email, role });

          set({
            user: mockUser,
            token: session.token,
            session,
            isAuthenticated: true,
            isLoading: false,
            loginError: null,
          });
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Login failed';
          set({ 
            isLoading: false,
            loginError: errorMessage,
          });
          throw new Error(errorMessage);
        }
      },

      logout: () => {
        const { user } = get();
        if (user) {
          createAuditLog(user.id, 'LOGOUT', 'auth', true);
        }
        
        set({
          user: null,
          token: null,
          session: null,
          isAuthenticated: false,
          loginError: null,
        });
      },

      register: async (userData: Partial<User>, password: string) => {
        set({ isLoading: true, loginError: null });
        
        try {
          await new Promise(resolve => setTimeout(resolve, 1000));
          
          // Check if user already exists
          if (mockUserDatabase.has(userData.email!)) {
            throw new Error('User already exists');
          }
          
          // Hash password
          const hashedPassword = await hashPassword(password);
          
          const newUser: User = {
            id: `user_${Date.now()}`,
            email: userData.email || '',
            name: userData.name || '',
            role: userData.role || 'citizen',
            cnic: userData.cnic,
            phone: userData.phone,
            province: userData.province,
            district: userData.district,
            isVerified: false,
            createdAt: new Date(),
          };

          // Store in mock database
          mockUserDatabase.set(newUser.email, {
            email: newUser.email,
            password: hashedPassword,
            userData: newUser,
          });

          // Create secure session
          const session = createSession(newUser.id);
          
          // Generate CSRF token
          generateCSRFToken();
          
          // Create audit log
          createAuditLog(newUser.id, 'REGISTER', 'auth', true, { email: newUser.email });

          set({
            user: newUser,
            token: session.token,
            session,
            isAuthenticated: true,
            isLoading: false,
            loginError: null,
          });
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Registration failed';
          set({ 
            isLoading: false,
            loginError: errorMessage,
          });
          throw new Error(errorMessage);
        }
      },

      updateUser: (userData: Partial<User>) => {
        set((state) => {
          const updatedUser = state.user ? { ...state.user, ...userData } : null;
          
          if (updatedUser) {
            createAuditLog(updatedUser.id, 'UPDATE_PROFILE', 'user', true, userData);
          }
          
          return { user: updatedUser };
        });
      },

      setLoading: (loading: boolean) => {
        set({ isLoading: loading });
      },

      setGovernmentRole: (role: GovernmentRole) => {
        set((state) => {
          if (!state.user) return state;
          
          const hierarchy = GOVERNMENT_HIERARCHY[role];
          
          const updatedUser: User = {
            ...state.user,
            governmentRole: role,
            employeeCode: `PAK-${role.toUpperCase()}-001`,
            designation: hierarchy?.title,
            approvalAuthority: hierarchy?.canApproveUpTo,
            name: hierarchy?.title || 'Government Official',
          };
          
          createAuditLog(updatedUser.id, 'SET_GOVERNMENT_ROLE', 'user', true, { role });
          
          return { user: updatedUser };
        });
      },

      checkSessionValidity: () => {
        const { session } = get();
        const isValid = validateSession(session);
        
        if (!isValid) {
          // Auto-logout if session invalid
          get().logout();
          return false;
        }
        
        return true;
      },

      refreshSession: () => {
        set((state) => {
          if (!state.session) return state;
          
          const updatedSession = updateSessionActivity(state.session);
          return { session: updatedSession };
        });
      },
    }),
    {
      name: STORAGE_KEYS.USER_DATA,
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        session: state.session,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
