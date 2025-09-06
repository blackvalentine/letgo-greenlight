package data

import (
	"database/sql"
	"errors"
	"time"
)

var (
	ErrRecordNotFound = errors.New("record not found")
	ErrEditConflict   = errors.New("edit conflict")
)

type MovieModelInterface interface {
	Insert(movie *Movie) error
	Get(id int64) (*Movie, error)
	Update(movie *Movie) error
	Delete(id int64) error
	GetAll(title string, genres []string, filters Filters) ([]*Movie, Metadata, error)
}

type UserModelInterface interface {
	Insert(user *User) error
	GetByEmail(email string) (*User, error)
	Update(user *User) error
	GetForToken(scope string, tokenPlaintext string) (*User, error)
}

type TokenModelInterface interface {
	New(userID int64, ttl time.Duration, scope string) (*Token, error)
	Insert(token *Token) error
	DeleteAllForUser(scope string, userID int64) error
}

type PermissionModelInterface interface {
	GetAllForUser(userId int64) (Permissions, error)
	AddForUser(userId int64, codes ...string) error
}

type Models struct {
	Movies      MovieModelInterface
	Users       UserModelInterface
	Tokens      TokenModelInterface
	Permissions PermissionModelInterface
}

func NewModels(db *sql.DB) Models {
	return Models{
		Movies:      MovieModel{DB: db},
		Users:       UserModel{DB: db},
		Tokens:      TokenModel{DB: db},
		Permissions: PermissionModel{DB: db},
	}
}

func NewMockModels() Models {
	return Models{
		Movies:      &MockMovieModel{},
		Users:       &MockUserModel{},
		Tokens:      &MockTokenModel{},
		Permissions: &MockPermissionModel{},
	}
}
