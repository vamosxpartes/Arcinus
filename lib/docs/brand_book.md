# Arcinus Sports Academy App
## Brand Book & Design Guidelines

---

## Table of Contents
1. [Brand Essence](#brand-essence)
2. [Color Palette](#color-palette)
3. [Typography](#typography)
4. [Logo & Identity](#logo--identity)
5. [UI Components](#ui-components)
6. [Layout Guidelines](#layout-guidelines)
7. [Navigation](#navigation)
8. [Iconography](#iconography)
9. [Image Treatment](#image-treatment)
10. [Voice & Tone](#voice--tone)

---

## Brand Essence

### Our Mission
Arcinus is a comprehensive platform designed for sports academies to manage athletes, coaches, training schedules, and performance tracking. Inspired by professional sports applications like the NBA app, Arcinus delivers a premium, dynamic experience for sports management.

### Brand Values
- **Excellence**: Pushing the boundaries of performance
- **Community**: Fostering team spirit and collaboration
- **Innovation**: Leveraging technology for athletic development
- **Accessibility**: Making sports management tools available for all levels

### Brand Personality
- Professional
- Dynamic
- Energetic
- Trustworthy
- Modern

---

## Color Palette

Our color palette draws inspiration from the intensity and energy of sports, creating a bold, dark-themed interface with vibrant accent colors.

### Primary Colors

| Color Name | Hex | RGB | CMYK | Sample |
|------------|-----|-----|------|--------|
| **Black Swarm** | `#000000` | 0, 0, 0 | 75, 0, 0, 100 | ![Black Swarm](https://via.placeholder.com/100x50/000000/FFFFFF?text=+) |
| **Bonfire Red** | `#da1a32` | 218, 26, 50 | 2, 100, 85, 6 | ![Bonfire Red](https://via.placeholder.com/100x50/da1a32/FFFFFF?text=+) |
| **Embers** | `#a00c30` | 160, 12, 48 | 8, 100, 70, 33 | ![Embers](https://via.placeholder.com/100x50/a00c30/FFFFFF?text=+) |
| **Magnolia White** | `#FFFFFF` | 255, 255, 255 | 0, 0, 0, 0 | ![Magnolia White](https://via.placeholder.com/100x50/FFFFFF/000000?text=+) |

### Secondary Colors

| Color Name | Hex | RGB | Sample |
|------------|-----|-----|--------|
| **Embers** | `#a00c30` | 160, 12, 48 | ![Embers](https://via.placeholder.com/100x50/a00c30/FFFFFF?text=+) |
| **Gold Trophy** | `#FFC400` | 255, 196, 0 | ![Gold Trophy](https://via.placeholder.com/100x50/FFC400/000000?text=+) |
| **Court Green** | `#00C853` | 0, 200, 83 | ![Court Green](https://via.placeholder.com/100x50/00C853/000000?text=+) |

### UI Grays

| Color Name | Hex | RGB | Sample |
|------------|-----|-----|--------|
| **Dark Gray** | `#1E1E1E` | 30, 30, 30 | ![Dark Gray](https://via.placeholder.com/100x50/1E1E1E/FFFFFF?text=+) |
| **Medium Gray** | `#323232` | 50, 50, 50 | ![Medium Gray](https://via.placeholder.com/100x50/323232/FFFFFF?text=+) |
| **Light Gray** | `#8A8A8A` | 138, 138, 138 | ![Light Gray](https://via.placeholder.com/100x50/8A8A8A/FFFFFF?text=+) |

### Color Usage

- **Black Swarm**: Primary background color for the app
- **Bonfire Red**: Primary action color, important notifications, critical information
- **Embers**: Secondary action color, section headers, important highlights
- **Magnolia White**: Text, icons, and UI elements on dark backgrounds
- **Embers**: Links, selected states, progress indicators
- **Gold Trophy**: Achievements, rewards, special highlights
- **Court Green**: Success states, positive metrics, completed items

---

## Typography

### Font Family

Roboto is our primary typeface, offering excellent readability across devices while maintaining a modern, clean aesthetic.

### Type Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| H1 | 32px | Black (900) | 1.2 | Main headers, splash screens |
| H2 | 24px | Bold (700) | 1.2 | Section headers |
| H3 | 20px | Bold (700) | 1.2 | Card titles, important labels |
| Subtitle | 18px | Medium (500) | 1.3 | Subheaders, feature introductions |
| Body | 16px | Regular (400) | 1.5 | Main content text |
| Secondary | 14px | Light (300) | 1.4 | Supporting text, metadata |
| Caption | 12px | Light (300) | 1.3 | Timestamps, footnotes |
| Button | 16px | Medium (500) | 1.0 | Button text |
| Stats | 48px | Black (900) | 1.1 | Key metrics, large numbers |

### Text Colors

- **Primary Text**: Magnolia White (`#FFFFFF`) on dark backgrounds
- **Secondary Text**: Light Gray (`#8A8A8A`) for supporting information
- **Disabled Text**: Medium Gray (`#5F5F5F`) for inactive elements
- **Error Text**: Bonfire Red (`#da1a32`) for error messages
- **Link Text**: Embers (`#a00c30`) for interactive text elements

---

## Logo & Identity

### Logo Variations

The Arcinus logo draws inspiration from sports imagery, specifically using a shark design that conveys speed, power, and precision. This is similar to the shark logos shown in images 4 and 5.

![Arcinus Logo](https://via.placeholder.com/300x150/000000/FFFFFF?text=Arcinus+Logo)

### Logo Usage

- **Minimum Size**: The logo should never appear smaller than 24px in height
- **Clear Space**: Maintain padding around the logo equal to 50% of its height
- **Background**: The logo can appear on Black Swarm, Embers, or Magnolia White
- **Don't**: Stretch, recolor outside of approved palette, rotate, or add effects to the logo

### App Icon

The app icon uses a simplified version of the shark logo against the Black Swarm background with Bonfire Red accents.

---

## UI Components

### Cards

Cards are a fundamental component of the Arcinus interface, used to display information about teams, athletes, coaches, and events.

#### Team/Player Card

Based on the NBA app shown in images 2, 3, and 8:

```
┌────────────────────────────┐
│ [Team Logo/Player Photo]   │
│                            │
│ Team/Player Name           │
│ Location/Position • Stats  │
│                            │
│ [Primary Action Button]    │
└────────────────────────────┘
```

#### Game/Event Card

Based on the NBA game cards shown in image 2:

```
┌────────────────────────────┐
│ [Team A] [Score] [Team B]  │
│ Record A         Record B  │
│                            │
│ [Time/Status]    [Date]    │
│                            │
│ [Action Buttons]           │
└────────────────────────────┘
```

### Buttons

#### Primary Button
- Background: Bonfire Red (`#da1a32`)
- Text: Magnolia White (`#FFFFFF`)
- Border Radius: 8px
- Height: 48px
- States: Normal, Hover, Pressed, Disabled

#### Secondary Button
- Background: Transparent
- Border: 2px Bonfire Red (`#da1a32`)
- Text: Bonfire Red (`#da1a32`)
- Border Radius: 8px
- Height: 48px

#### Text Button
- No background
- Text: Embers (`#a00c30`)
- Height: 40px

#### Action Button
- Circular shape
- Background: Embers (`#a00c30`)
- Icon: Magnolia White (`#FFFFFF`)
- Diameter: 56px

### Form Elements

#### Text Fields
- Background: Medium Gray (`#323232`)
- Text: Magnolia White (`#FFFFFF`)
- Border Radius: 8px
- Height: 48px
- States: Normal, Focus, Error, Disabled

#### Dropdowns & Selectors
- Similar styling to text fields
- Include a chevron icon to indicate dropdown functionality
- Selected state highlighted with Embers (`#a00c30`)

### Progress Indicators

#### Loading Spinner
- Color: Embers (`#a00c30`)
- Size: 24px for inline, 48px for full-screen loading

#### Progress Bar
- Background: Medium Gray (`#323232`)
- Fill: Embers (`#a00c30`) or Court Green (`#00C853`) depending on context

---

## Layout Guidelines

### Grid System

- **Base Grid**: 8px grid for spacing and component sizing
- **Margins**: 16px minimum margin from screen edges
- **Gutters**: 8px minimum between elements

### Screen Layouts

#### Dashboard Layout

```
┌────────────────────────────┐
│ [Status Bar]               │
├────────────────────────────┤
│ [Header w/ Navigation]     │
├────────────────────────────┤
│                            │
│ [Primary Content Area]     │
│                            │
│                            │
│                            │
│                            │
│                            │
├────────────────────────────┤
│ [Bottom Navigation]        │
└────────────────────────────┘
```

#### Detail Screen Layout

```
┌────────────────────────────┐
│ [Status Bar]               │
├────────────────────────────┤
│ [Back] [Title]    [Actions]│
├────────────────────────────┤
│ [Header Image/Info]        │
├────────────────────────────┤
│ [Tab Navigation]           │
├────────────────────────────┤
│                            │
│ [Tab Content]              │
│                            │
│                            │
│                            │
├────────────────────────────┤
│ [Bottom Navigation]        │
└────────────────────────────┘
```

### Responsive Behavior

- Design is mobile-first, with tablet and desktop adaptations
- Elements stack vertically on small screens
- Cards expand to fill available width with minimum and maximum widths
- Grid layouts adapt from 1 column (mobile) to 2-3 columns (tablet/desktop)

---

## Navigation

### Bottom Navigation

Based on image 9, the bottom navigation features 5 key destinations:

```
┌───────┬───────┬───────┬───────┬───────┐
│       │       │       │       │       │
│ Home  │ Search │ Stats │ Notif.│ Profile│
│       │       │       │       │       │
└───────┴───────┴───────┴───────┴───────┘
```

- Active state: Embers (`#a00c30`) with text label
- Inactive state: Light Gray (`#8A8A8A`) with text label
- Sliding indicator under the active tab

### Tab Navigation

For secondary navigation within screens:

```
┌───────────┬───────────┬───────────┐
│  Tab 1    │  Tab 2    │  Tab 3    │
└───────────┴───────────┴───────────┘
```

- Active state: Underlined with Embers (`#a00c30`), text in Magnolia White
- Inactive state: No underline, text in Light Gray

### Gesture Navigation

- Swipe horizontally to navigate between related screens/tabs
- Pull to refresh content
- Swipe vertically to scroll content

---

## Iconography

### Style Guide

- Line weight: 2px
- Corner radius: 2px
- Size: 24×24px (standard), 16×16px (small), 32×32px (large)
- Color: Magnolia White (`#FFFFFF`) for most UI contexts

### Primary Navigation Icons

| Icon | Name | Usage |
|------|------|-------|
| ![Home](https://via.placeholder.com/24x24/000000/FFFFFF?text=🏠) | Home | Navigate to home screen |
| ![Search](https://via.placeholder.com/24x24/000000/FFFFFF?text=🔍) | Search | Access search functionality |
| ![Stats](https://via.placeholder.com/24x24/000000/FFFFFF?text=📊) | Stats | View statistics and metrics |
| ![Notification](https://via.placeholder.com/24x24/000000/FFFFFF?text=🔔) | Notification | View notifications |
| ![Profile](https://via.placeholder.com/24x24/000000/FFFFFF?text=👤) | Profile | Access user profile |

### Action Icons

| Icon | Name | Usage |
|------|------|-------|
| ![Add](https://via.placeholder.com/24x24/000000/FFFFFF?text=➕) | Add | Create new item |
| ![Edit](https://via.placeholder.com/24x24/000000/FFFFFF?text=✏️) | Edit | Modify existing content |
| ![Delete](https://via.placeholder.com/24x24/000000/FFFFFF?text=🗑️) | Delete | Remove content |
| ![Share](https://via.placeholder.com/24x24/000000/FFFFFF?text=↗️) | Share | Share content |
| ![More](https://via.placeholder.com/24x24/000000/FFFFFF?text=⋯) | More | Additional options |

---

## Image Treatment

### Profile Photos

- Circular crop
- Resolution: Minimum 200×200px, ideally 400×400px
- Background: Dark gray if photo unavailable
- Border: 2px white for selected/active state

### Team/Academy Logos

- Square or circular container
- Transparent background preferred
- High contrast against dark backgrounds

### Background Images

- Overlay: Black gradient (0% to 70% opacity)
- Image brightness reduced by 15-20% for better text contrast
- Text protection: Critical UI text should have sufficient contrast

---

## Voice & Tone

### Writing Principles

- **Clear**: Use simple, direct language
- **Concise**: Keep text brief and focused
- **Actionable**: Guide users with clear calls to action
- **Energetic**: Match the dynamism of sports

### Messaging Examples

#### Success Messages
- "Great job! Training session scheduled."
- "Athlete added to team successfully."

#### Error Messages
- "Unable to save changes. Please try again."
- "Connection lost. Check your network."

#### Empty States
- "No upcoming events. Schedule one to get started."
- "No athletes added yet. Add your first athlete."

#### Calls to Action
- "Schedule Training"
- "View Performance"
- "Add Athletes"

---

## Implementation Guidelines

### Development Standards

- Flutter-based UI following Material Design principles
- Responsive layout using Flex and MediaQuery
- Consistent naming conventions for components
- Platform-specific adaptations when necessary

### Accessibility Considerations

- Minimum contrast ratio of 4.5:1 for normal text
- Interactive elements minimum touch target of 44×44px
- Support for screen readers and assistive technologies
- Keyboard navigation support for web interfaces

### Performance Optimization

- Optimize image sizes and resolution
- Lazy loading for lists and image-heavy content
- Smooth animations targeted at 60fps
- Cache commonly used data for offline access

---

&copy; 2025 Arcinus Sports Management Platform