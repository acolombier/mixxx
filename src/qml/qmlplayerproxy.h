#pragma once
#include <qglobal.h>
#include <qobject.h>

#include <QColor>
#include <QObject>
#include <QPointer>
#include <QQmlEngine>
#include <QString>
#include <QUrl>

#include "mixer/basetrackplayer.h"
#include "qml/qmlbeatsmodel.h"
#include "qml/qmlcuesmodel.h"
#include "qml/qmlstemsmodel.h"
#include "track/track_decl.h"
#include "waveform/waveform.h"

namespace mixxx {
namespace qml {

class QmlTrackProxy : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString artist READ getArtist WRITE setArtist NOTIFY artistChanged)
    Q_PROPERTY(QString title READ getTitle WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString album READ getAlbum WRITE setAlbum NOTIFY albumChanged)
    Q_PROPERTY(QString albumArtist READ getAlbumArtist WRITE setAlbumArtist
                    NOTIFY albumArtistChanged)
    Q_PROPERTY(QString genre READ getGenre STORED false NOTIFY genreChanged)
    Q_PROPERTY(QString composer READ getComposer WRITE setComposer NOTIFY composerChanged)
    Q_PROPERTY(QString grouping READ getGrouping WRITE setGrouping NOTIFY groupingChanged)
    Q_PROPERTY(int stars READ getStars WRITE setStars NOTIFY starsChanged)
    Q_PROPERTY(QString year READ getYear WRITE setYear NOTIFY yearChanged)
    Q_PROPERTY(QString trackNumber READ getTrackNumber WRITE setTrackNumber
                    NOTIFY trackNumberChanged)
    Q_PROPERTY(QString trackTotal READ getTrackTotal WRITE setTrackTotal NOTIFY trackTotalChanged)
    Q_PROPERTY(QString comment READ getComment WRITE setComment NOTIFY commentChanged)
    Q_PROPERTY(QString keyText READ getKeyText WRITE setKeyText NOTIFY keyTextChanged)
    Q_PROPERTY(QColor color READ getColor WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(double duration READ getDuration NOTIFY durationChanged)
    Q_PROPERTY(int sampleRate READ getSampleRate NOTIFY sampleRateChanged)
    Q_PROPERTY(QUrl coverArtUrl READ getCoverArtUrl NOTIFY coverArtUrlChanged)
    Q_PROPERTY(QUrl trackLocationUrl READ getTrackLocationUrl NOTIFY trackLocationUrlChanged)

    Q_PROPERTY(mixxx::qml::QmlBeatsModel* beatsModel MEMBER m_pBeatsModel CONSTANT);
    Q_PROPERTY(mixxx::qml::QmlCuesModel* hotcuesModel MEMBER m_pHotcuesModel CONSTANT);
#ifdef __STEM__
    Q_PROPERTY(mixxx::qml::QmlStemsModel* stemsModel READ getStemsModel CONSTANT);
#endif

    QML_NAMED_ELEMENT(Track)
    QML_UNCREATABLE("Only accessible via Mixxx.PlayerManager and Mixxx.Library")
  public:
    explicit QmlTrackProxy(TrackPointer track, QObject* parent = nullptr);

    QString getTrack() const;
    QString getTitle() const;
    QString getArtist() const;
    QString getAlbum() const;
    QString getAlbumArtist() const;
    QString getGenre() const;
    QString getComposer() const;
    QString getGrouping() const;
    QString getYear() const;
    int getStars() const;
    QString getTrackNumber() const;
    QString getTrackTotal() const;
    QString getComment() const;
    QString getKeyText() const;
    QColor getColor() const;
    double getDuration() const;
    int getSampleRate() const;
    QUrl getCoverArtUrl() const;
    QUrl getTrackLocationUrl() const;

#ifdef __STEM__
    QmlStemsModel* getStemsModel() const {
        return m_pStemsModel.get();
    }
#endif

    TrackPointer internal() const {
        return m_pTrack;
    }

  public slots:
    void slotBeatsChanged();
    void slotHotcuesChanged();
#ifdef __STEM__
    void slotStemsChanged();
#endif

    void setArtist(const QString& artist);
    void setTitle(const QString& title);
    void setAlbum(const QString& album);
    void setAlbumArtist(const QString& albumArtist);
    void setComposer(const QString& composer);
    void setGrouping(const QString& grouping);
    void setStars(int stars);
    void setYear(const QString& year);
    void setTrackNumber(const QString& trackNumber);
    void setTrackTotal(const QString& trackTotal);
    void setComment(const QString& comment);
    void setKeyText(const QString& keyText);
    void setColor(const QColor& color);

  signals:
    void albumChanged();
    void titleChanged();
    void artistChanged();
    void albumArtistChanged();
    void genreChanged();
    void composerChanged();
    void groupingChanged();
    void starsChanged();
    void yearChanged();
    void trackNumberChanged();
    void trackTotalChanged();
    void commentChanged();
    void keyTextChanged();
    void colorChanged();
    void durationChanged();
    void sampleRateChanged();
    void coverArtUrlChanged();
    void trackLocationUrlChanged();
    void cuesChanged();
#ifdef __STEM__
    void stemsChanged();
#endif

  private:
    TrackPointer m_pTrack;
    QmlBeatsModel* m_pBeatsModel;
    QmlCuesModel* m_pHotcuesModel;
#ifdef __STEM__
    std::unique_ptr<QmlStemsModel> m_pStemsModel;
#endif
};

class QmlPlayerProxy : public QObject {
    Q_OBJECT
    Q_PROPERTY(QmlTrackProxy* currentTrack READ currentTrack NOTIFY trackChanged)
    Q_PROPERTY(bool isLoaded READ isLoaded NOTIFY trackChanged)
    QML_NAMED_ELEMENT(Player)
    QML_UNCREATABLE("Only accessible via Mixxx.PlayerManager.getPlayer(group)")

  public:
    explicit QmlPlayerProxy(BaseTrackPlayer* pTrackPlayer, QObject* parent = nullptr);

    bool isLoaded() const;
    /// Needed for interacting with the raw track player object.
    BaseTrackPlayer* internalTrackPlayer() const {
        return m_pTrackPlayer;
    }

    Q_INVOKABLE void loadTrack(QmlTrackProxy* track, bool play = false);
    Q_INVOKABLE void loadTrackFromLocation(const QString& trackLocation, bool play = false);
    Q_INVOKABLE void loadTrackFromLocationUrl(const QUrl& trackLocationUrl, bool play = false);

    QmlTrackProxy* currentTrack() {
        return new QmlTrackProxy(m_pCurrentTrack, this);
    }

  public slots:
    void slotTrackLoaded(TrackPointer pTrack);
    void slotTrackUnloaded(TrackPointer pOldTrack);
    void slotLoadingTrack(TrackPointer pNewTrack, TrackPointer pOldTrack);

  signals:
    void trackLoading();
    void trackLoaded();
    void trackUnloaded();
    void trackChanged();
    void cloneFromGroup(const QString& group);

    void loadTrackFromLocationRequested(const QString& trackLocation, bool play);
    void loadTrackRequested(TrackPointer track,
            mixxx::StemChannelSelection stemSelection,
            bool play);

  private:
    QPointer<BaseTrackPlayer> m_pTrackPlayer;
    TrackPointer m_pCurrentTrack;
};

} // namespace qml
} // namespace mixxx

Q_DECLARE_METATYPE(mixxx::qml::QmlTrackProxy*)
