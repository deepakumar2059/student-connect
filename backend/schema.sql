-- PostgreSQL schema for Student Connect collaboration platform
-- Uses UUID primary keys and normalized structures for profiles, projects, messaging, moderation, and analytics.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enum types
CREATE TYPE visibility_enum AS ENUM ('public_college', 'private', 'selective');
CREATE TYPE skill_category_enum AS ENUM ('technical', 'design', 'business', 'research', 'soft', 'other');
CREATE TYPE proficiency_enum AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE experience_type_enum AS ENUM ('project', 'hackathon', 'research', 'internship', 'achievement', 'other');
CREATE TYPE project_stage_enum AS ENUM ('idea', 'in_progress', 'near_completion');
CREATE TYPE project_status_enum AS ENUM ('open', 'in_progress', 'closed', 'completed', 'archived', 'paused');
CREATE TYPE commitment_level_enum AS ENUM ('low', 'medium', 'high');
CREATE TYPE remote_preference_enum AS ENUM ('remote', 'hybrid', 'in_person');
CREATE TYPE application_status_enum AS ENUM ('pending', 'shortlisted', 'accepted', 'rejected', 'withdrawn');
CREATE TYPE member_role_enum AS ENUM ('owner', 'core', 'contributor', 'helper', 'custom');
CREATE TYPE member_status_enum AS ENUM ('active', 'left', 'removed');
CREATE TYPE invitation_status_enum AS ENUM ('pending', 'accepted', 'declined', 'expired');
CREATE TYPE conversation_type_enum AS ENUM ('direct', 'project_group');
CREATE TYPE message_type_enum AS ENUM ('text', 'system', 'file');
CREATE TYPE user_role_enum AS ENUM ('student', 'faculty', 'admin', 'club_admin');
CREATE TYPE reported_entity_type_enum AS ENUM ('user', 'project', 'message', 'comment');
CREATE TYPE report_status_enum AS ENUM ('pending', 'reviewed', 'actioned', 'dismissed');
CREATE TYPE link_type_enum AS ENUM ('github', 'linkedin', 'portfolio', 'other');
CREATE TYPE notification_type_enum AS ENUM ('application_received', 'accepted', 'project_update', 'message', 'skill_match', 'endorsement', 'invitation', 'general');
CREATE TYPE project_attachment_type_enum AS ENUM ('document', 'mockup', 'pitch', 'github', 'demo', 'other');
CREATE TYPE project_update_comment_status_enum AS ENUM ('visible', 'hidden');

-- Institutions and core identity
CREATE TABLE colleges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  short_code TEXT,
  domain TEXT,
  logo_url TEXT,
  website TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  college_id UUID NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  code TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_departments_college_id ON departments(college_id);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT,
  college_id UUID NOT NULL REFERENCES colleges(id) ON DELETE RESTRICT,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  year_of_study SMALLINT,
  full_name TEXT NOT NULL,
  bio TEXT,
  profile_photo_url TEXT,
  visibility visibility_enum NOT NULL DEFAULT 'public_college',
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  verification_method TEXT,
  profile_completeness_score INT NOT NULL DEFAULT 0,
  open_to_collaborate BOOLEAN NOT NULL DEFAULT TRUE,
  availability_hours_per_week INT,
  preferred_roles TEXT[] DEFAULT ARRAY[]::TEXT[],
  preferred_project_types TEXT[] DEFAULT ARRAY[]::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  last_active_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  status TEXT NOT NULL DEFAULT 'active'
);

CREATE INDEX idx_users_college_id ON users(college_id);
CREATE INDEX idx_users_department_id ON users(department_id);
CREATE INDEX idx_users_visibility ON users(visibility);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_preferred_roles ON users USING GIN (preferred_roles);
CREATE INDEX idx_users_preferred_project_types ON users USING GIN (preferred_project_types);

CREATE TABLE user_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type link_type_enum NOT NULL,
  url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_links_user_id ON user_links(user_id);

-- Skills system
CREATE TABLE skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  category skill_category_enum NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE user_skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  proficiency proficiency_enum NOT NULL,
  self_rating SMALLINT CHECK (self_rating BETWEEN 1 AND 5),
  years_experience INT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, skill_id)
);

CREATE INDEX idx_user_skills_user_id ON user_skills(user_id);
CREATE INDEX idx_user_skills_skill_id ON user_skills(skill_id);
CREATE INDEX idx_user_skills_proficiency ON user_skills(proficiency);

-- Experience / portfolio
CREATE TABLE user_experiences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type experience_type_enum NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  start_date DATE,
  end_date DATE,
  organization TEXT,
  venue TEXT,
  link_url TEXT,
  skills_used UUID[] DEFAULT ARRAY[]::UUID[],
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_experiences_user_id ON user_experiences(user_id);
CREATE INDEX idx_user_experiences_skills_used ON user_experiences USING GIN (skills_used);

-- Projects and posting
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  college_id UUID NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  goals TEXT,
  outcomes TEXT,
  stage project_stage_enum NOT NULL DEFAULT 'idea',
  status project_status_enum NOT NULL DEFAULT 'open',
  preferred_team_size_min INT,
  preferred_team_size_max INT,
  timeline_start DATE,
  timeline_end DATE,
  duration_weeks INT,
  commitment_level commitment_level_enum,
  remote_preference remote_preference_enum,
  prerequisites TEXT,
  looking_for_summary TEXT,
  published_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_projects_owner_id ON projects(owner_id);
CREATE INDEX idx_projects_college_id ON projects(college_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_stage ON projects(stage);

CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE project_tags (
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  PRIMARY KEY (project_id, tag_id)
);

CREATE INDEX idx_project_tags_tag_id ON project_tags(tag_id);

CREATE TABLE project_skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE RESTRICT,
  people_needed INT NOT NULL DEFAULT 1,
  role_title TEXT,
  is_required BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_project_skills_project_id ON project_skills(project_id);
CREATE INDEX idx_project_skills_skill_id ON project_skills(skill_id);

CREATE TABLE skill_endorsements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_skill_id UUID NOT NULL REFERENCES user_skills(id) ON DELETE CASCADE,
  endorser_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  message TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(endorser_id, user_skill_id)
);

CREATE TABLE project_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  type project_attachment_type_enum NOT NULL,
  url TEXT NOT NULL,
  title TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_project_attachments_project_id ON project_attachments(project_id);

CREATE TABLE project_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_project_updates_project_id ON project_updates(project_id);
CREATE INDEX idx_project_updates_author_id ON project_updates(author_id);

CREATE TABLE project_update_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_update_id UUID NOT NULL REFERENCES project_updates(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  parent_id UUID REFERENCES project_update_comments(id) ON DELETE CASCADE,
  status project_update_comment_status_enum NOT NULL DEFAULT 'visible',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_project_update_comments_update_id ON project_update_comments(project_update_id);
CREATE INDEX idx_project_update_comments_author_id ON project_update_comments(author_id);

-- Applications and team formation
CREATE TABLE project_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  applicant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message TEXT,
  status application_status_enum NOT NULL DEFAULT 'pending',
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(project_id, applicant_id)
);

CREATE INDEX idx_project_applications_project_id ON project_applications(project_id);
CREATE INDEX idx_project_applications_applicant_id ON project_applications(applicant_id);
CREATE INDEX idx_project_applications_status ON project_applications(status);

CREATE TABLE project_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role member_role_enum NOT NULL DEFAULT 'contributor',
  role_title TEXT,
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  left_at TIMESTAMP WITH TIME ZONE,
  status member_status_enum NOT NULL DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(project_id, user_id, status) WHERE status = 'active'
);

CREATE INDEX idx_project_members_project_id ON project_members(project_id);
CREATE INDEX idx_project_members_user_id ON project_members(user_id);

CREATE TABLE project_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  invitee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message TEXT,
  status invitation_status_enum NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  responded_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_project_invitations_project_id ON project_invitations(project_id);
CREATE INDEX idx_project_invitations_invitee_id ON project_invitations(invitee_id);

-- Communication
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type conversation_type_enum NOT NULL,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_conversations_project_id ON conversations(project_id);

CREATE TABLE conversation_participants (
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  left_at TIMESTAMP WITH TIME ZONE,
  last_read_at TIMESTAMP WITH TIME ZONE,
  PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  content TEXT,
  message_type message_type_enum NOT NULL DEFAULT 'text',
  attachment_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  edited_at TIMESTAMP WITH TIME ZONE,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);

-- Notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type notification_type_enum NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  data JSONB,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  related_entity_type TEXT,
  related_entity_id UUID
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_data ON notifications USING GIN (data);

-- Social, trust, reputation
CREATE TABLE project_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reviewee_id UUID REFERENCES users(id) ON DELETE SET NULL,
  collaboration_rating SMALLINT NOT NULL CHECK (collaboration_rating BETWEEN 1 AND 5),
  skills_demonstrated JSONB,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(project_id, reviewer_id, reviewee_id)
);

CREATE INDEX idx_project_reviews_project_id ON project_reviews(project_id);
CREATE INDEX idx_project_reviews_reviewer_id ON project_reviews(reviewer_id);

CREATE TABLE follows (
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  PRIMARY KEY (follower_id, following_user_id, following_project_id),
  CHECK (following_user_id IS NOT NULL OR following_project_id IS NOT NULL)
);

CREATE INDEX idx_follows_follower_id ON follows(follower_id);
CREATE INDEX idx_follows_following_user_id ON follows(following_user_id);
CREATE INDEX idx_follows_following_project_id ON follows(following_project_id);

CREATE TABLE saved_projects (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, project_id)
);

CREATE INDEX idx_saved_projects_project_id ON saved_projects(project_id);

CREATE TABLE user_reputation (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  projects_completed INT NOT NULL DEFAULT 0,
  endorsements_received INT NOT NULL DEFAULT 0,
  average_rating NUMERIC(3,2) NOT NULL DEFAULT 0,
  contribution_score NUMERIC(8,2) NOT NULL DEFAULT 0,
  last_calculated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Institution, administration, clubs
CREATE TABLE user_roles (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role user_role_enum NOT NULL,
  college_id UUID REFERENCES colleges(id) ON DELETE CASCADE,
  granted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, role, college_id)
);

CREATE TABLE clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  college_id UUID NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE club_members (
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  PRIMARY KEY (club_id, user_id)
);

CREATE TABLE club_projects (
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  PRIMARY KEY (club_id, project_id)
);

CREATE TABLE announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  college_id UUID NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  event_date TIMESTAMP WITH TIME ZONE,
  link_project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Safety and moderation
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reported_entity_type reported_entity_type_enum NOT NULL,
  reported_entity_id UUID NOT NULL,
  reason TEXT NOT NULL,
  description TEXT,
  status report_status_enum NOT NULL DEFAULT 'pending',
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_reports_reporter_id ON reports(reporter_id);
CREATE INDEX idx_reports_status ON reports(status);

CREATE TABLE blocks (
  blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id)
);

CREATE TABLE moderation_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  moderator_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Indexes for frequently queried columns
CREATE INDEX idx_projects_preferred_stage_status ON projects(stage, status);
CREATE INDEX idx_projects_timeline_start ON projects(timeline_start);
CREATE INDEX idx_project_updates_created_at ON project_updates(created_at);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_users_last_active_at ON users(last_active_at);
