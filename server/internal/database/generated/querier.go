// Code generated by sqlc. DO NOT EDIT.
// versions:
//   sqlc v1.29.0

package database

import (
	"context"

	"github.com/google/uuid"
)

type Querier interface {
	CreateAPIKey(ctx context.Context, arg CreateAPIKeyParams) (ApiKeys, error)
	CreateProject(ctx context.Context, arg CreateProjectParams) (Projects, error)
	CreateSpace(ctx context.Context, arg CreateSpaceParams) (Spaces, error)
	CreateUser(ctx context.Context, arg CreateUserParams) (Users, error)
	DeleteAPIKey(ctx context.Context, id uuid.UUID) error
	DeleteProject(ctx context.Context, id uuid.UUID) error
	DeleteSpace(ctx context.Context, id uuid.UUID) error
	DeleteUser(ctx context.Context, id uuid.UUID) error
	GetAPIKey(ctx context.Context, id uuid.UUID) (ApiKeys, error)
	GetAPIKeyByHash(ctx context.Context, keyHash string) (ApiKeys, error)
	GetAPIKeyByPrefix(ctx context.Context, keyPrefix string) (ApiKeys, error)
	GetProject(ctx context.Context, id uuid.UUID) (Projects, error)
	GetProjectBySlug(ctx context.Context, arg GetProjectBySlugParams) (Projects, error)
	GetSpace(ctx context.Context, id uuid.UUID) (Spaces, error)
	GetSpaceBySlug(ctx context.Context, slug string) (Spaces, error)
	GetUser(ctx context.Context, id uuid.UUID) (Users, error)
	GetUserByEmail(ctx context.Context, email string) (Users, error)
	ListAPIKeysByProject(ctx context.Context, projectID uuid.UUID) ([]ApiKeys, error)
	ListProjectsBySpace(ctx context.Context, spaceID uuid.UUID) ([]Projects, error)
	ListSpaces(ctx context.Context) ([]Spaces, error)
	ListUsersBySpace(ctx context.Context, spaceID uuid.UUID) ([]Users, error)
	UpdateAPIKeyLastUsed(ctx context.Context, id uuid.UUID) error
	UpdateProject(ctx context.Context, arg UpdateProjectParams) (Projects, error)
	UpdateSpace(ctx context.Context, arg UpdateSpaceParams) (Spaces, error)
	UpdateUser(ctx context.Context, arg UpdateUserParams) (Users, error)
}

var _ Querier = (*Queries)(nil)
