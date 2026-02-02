Project Title

Smart Office Resource Management System

Project Overview

The Smart Office Resource Management System is a controlled-access web platform that manages shared office resources through an admin-governed booking workflow. The system enforces conflict-free scheduling, approval-based allocation, and utilization tracking while ensuring that all users are provisioned exclusively by an administrator.

Employees cannot self-register. All accounts are created and managed centrally to maintain identity integrity and audit reliability.

Access Model (Critical Rule)

No public signup exists.

Only admin can create employee accounts.

Users can only log in with credentials issued by admin.

Every action is traceable to a real pre-created identity.

This prevents fake accounts and preserves audit validity.

This is an internal enterprise system, not a public app.

User Roles
Admin (system authority)

create and manage users

create and manage resources

manage holidays

approve / reject / modify bookings

view audit logs

view reports

Employee

login only

request bookings

cancel upcoming bookings

check-in to approved bookings

receive notifications

view availability

No employee can create another user.

Objectives

centralized user provisioning

strict admin approval pipeline

eliminate booking conflicts

measure actual resource utilization

maintain full audit trail

provide operational transparency

support flexible resource definitions

Core Functional Features
User Management

admin-only user creation

no public registration endpoint

secure login via JWT

role stored in database

users cannot escalate privileges

Resource Management

dynamic resource schema via JSONB

admin-managed catalog

resources can be deactivated

Booking System

30-minute slot granularity

Mon–Fri, 9am–6pm only

holidays blocked

multiple pending allowed

admin approval required

no overlapping approved bookings

Approval Workflow

FCFS visible queue

approving one auto-rejects conflicts

admin can modify bookings

messages stored with decision

Check-in Enforcement

reminder 15 minutes before start

15-minute grace window

no check-in → auto-release

new request required after release

Cancellation

allowed only before start time

Notifications

email + in-app

triggered by status change

Audit System

immutable state-change logs

tracks all admin decisions

Reporting

utilization based on check-in

booking pattern analysis

under/overused resources

Technical Architecture

Backend:

Ruby on Rails API

PostgreSQL

JWT authentication

JSONB resource attributes

Sidekiq background jobs

Security Model:

admin-provisioned accounts only

no signup routes

role-based authorization guards

Automation:

pending expiry job

auto-release job

reminder scheduler

System Constraints

single shared admin identity

no public registration

no recurring bookings

no checkout tracking

fixed office hours

admin is approval bottleneck